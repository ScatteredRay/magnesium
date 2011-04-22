require 'build'
require 'protocol/build.pb'

require 'rubygems'
require 'amqp'

def do_build(message)
  user_id = 0
  project_id = 0
  build_slot = 0
  dest_url = "http://arelius.com/Idtor/"

  build_directory = Build.gen_build_path(user_id, project_id, build_slot)

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

  ipa_file = Build.copy_ipa(Build.build_ipa(build_directory, message.ConfigName, message.Target), user_id, project_id, build_slot)
  # We need to pull this info out of the project.
  manifest = Build.render_manifest(build_directory, dest_url, message.Target, message.ConfigName, project)

  Build.clean_build(build_directory);

  if(File.exists?(ipa_path))
    # Build Error
  end
  
  ret = BuildSuccess.new
  ret.Manifest = manifest
  # This can't work for large IPA's we need some sort of streaming protocol.
  File.open(ipa_file, "r") do |f|
    ret.IPA = f.read()
  end
  FileUtils.remove(ipa_path)
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
