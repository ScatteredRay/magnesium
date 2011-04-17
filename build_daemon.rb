require 'build'
require 'protocol/build.pb'

require 'rubygems'
require 'amqp'

def do_build(message)
  build_directory = "/Users/indy/dev/tmpbuilddir"
  dest_url = "http://arelius.com/Idtor/"

  Build.init_build_directory(build_directory, message.GitRepo);

  File.open(build_directory + "/Certificate.p12", "w");
  Build.install_certificate(build_directory + "/Certificate.p12") # *.cer works?

  project = Build.parse_project(build_directory, message.Project)

  build_msg = ''
  ret = Build.run_xcode_build(build_directory,
                              message.Project,
                              message.Target,
                              message.ConfigName,
                              message.SDK,
                              build_msg)
  if(!ret)
    print build_msg
  end

  ipa_file = Build.build_ipa(build_directory, message.ConfigName, message.Target)
  # We need to pull this info out of the project.
  manifest = Build.render_manifest(build_directory, dest_url, message.Target, message.ConfigName, project)
  ret = BuildSuccess.new
  ret.Manifest = manifest
  # This can't work for large IPA's we need some sort of streaming protocol.
  File.open(ipa_file, "r") do |f|
    ret.IPA = f.read()
  end
  return ret;
end

AMQP.start(:host => "victoria.bitbane.com",
           :user => "guest",
           :pass => "guest",
           :vhost => "/") do |conn|
  amq = AMQP::Channel.new
  queue = amq.queue("build")

  queue.subscribe do |msg|
    do_build(BuildRequest.new.parse_from_string(msg).Begin)
  end
end
