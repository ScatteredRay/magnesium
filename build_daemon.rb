require 'build'
require 'build.pb'

def do_build(message)
  build_directory = "/Users/indy/dev/tmpbuilddir"
  dest_url = "http://arelius.com/Idtor/"

  Build.init_build_directory(build_directory, message.GitRepo);

  File.open(build_directory + "/Certificate.p12", "w");
  Build.install_certificate(build_directory + "/Certificate.p12") # *.cer works?

  Build.parse_project(build_directory, message.Project)

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
  manifest = Build.render_manifest(dest_url, message.Target,
                                   "com.ibuild.Idtor",
                                   "1.0 (1.0)")
  ret = BuildSuccess.new
  ret.Manifest = manifest
  # This can't work for large IPA's we need some sort of streaming protocol.
  File.open(ipa_file, "r") do |f|
    ret.IPA = f.read()
  end
  return ret;
end

GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

build_message = BuildBegin.new
build_message.GitRepo = GitRepo
build_message.Project = ProjName
build_message.Target = Target
build_message.ConfigName = ConfigName
build_message.SDK = SDKName
#File.open("Certificate.p12", "r") do |f|
#  build_message.Certificate = f.read()
#end
build_message.Certificate = ""

str = ''
build_message.serialize_to_string(str)

message = BuildBegin.new
message.parse_from_string(str)

do_build(message)
