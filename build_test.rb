require 'build'

GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

build_directory = "/Users/indy/dev/tmpbuilddir"
dest_url = "http://arelius.com/Idtor/"

Build.init_build_directory(build_directory, GitRepo);
Build.install_certificate(build_directory + "/Certificate.p12") # *.cer works?
project = Build.parse_project(build_directory, ProjName)

build_msg = ''
ret = Build.run_xcode_build(build_directory,
                            ProjName,
                            Target,
                            ConfigName,
                            SDKName,
                            build_msg)
#if(!ret)
  print build_msg
#end

ipa_file = Build.build_ipa(build_directory, ConfigName, Target)
  # We need to pull this info out of the project.
manifest = Build.render_manifest(build_directory, dest_url, Target, ConfigName, project)


