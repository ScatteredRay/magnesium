require 'rubygems'
require 'git'
require 'mustache'

def init_build_directory(build_directory, git_repo)
  begin
    Dir.mkdir(build_directory)
  rescue Errno::EEXIST
    # Directory exists!
  end

  begin
    Git.clone(git_repo, build_directory);
  rescue Git::GitExecuteError
    # Git clone error.
  end
end

def install_certificate(dev_cert)
  # Take care of certs and provisioning profiles.
  cert_pass = "1233456789" # Perhaps we should generate this randomlly?
  #system("security import #{dev_cert} -k ~/Library/Keychains/login.keychain -P #{cert_pass} -T /usr/bin/codesign")
  # *.xcodeproj/project.pbxproj has CODE_SIGN_IDENTITY make sure those match the cert. just installed.
end

def run_xcode_build(build_directory, proj_name, target, config_name, sdk_name)
  # Do the build.
  source_dir = Dir.pwd
  Dir.chdir(build_directory);
  ret = system("xcodebuild -project #{proj_name} -target #{target} -configuration #{config_name} -sdk #{sdk_name}")

  if(!ret)
    # build error
    # $?
  end
  Dir.chdir(source_dir);
end

def build_ipa(build_directory, config_name, target)
  source_dir = Dir.pwd
  build_path = build_directory + "/build/#{config_name}-iphoneos"
  app_path = build_path + "/#{target}.app"
  ipa_path = build_path + "/#{target}.ipa"
  payload = build_path + "/payload/"

  # Fail on error here.
  Dir.mkdir(payload)
  FileUtils.cp_r(app_path, payload)

  Dir.chdir(build_path)
  ret = system("zip -r #{target}.ipa payload")
  # fail on ret
  Dir.chdir(source_dir);

  return ipa_path;
end

def render_manifest(dest_url, target, bundle_id, version, title)
  Mustache.template_file = "manifest.plist"
  view = Mustache.new
  view[:PackageUrl] = dest_url + "#{target}.ipa"
  view[:DisplayImageUrl] = dest_url + "Icon.png"
  view[:FullImageUrl] = dest_url + "Icon.png"

  view[:bundle_id] = bundle_id
  view[:version] = version
  view[:title] = title
  return view.render()
end

BuildDirectory = "/Users/indy/dev/tmpbuilddir"
GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

DestUrl = "http://arelius.com/Idtor/"

init_build_directory(BuildDirectory, GitRepo);
install_certificate("Certificate.p12") # *.cer works?
run_xcode_build(BuildDirectory, ProjName, Target, ConfigName, SDKName)
build_ipa(BuildDirectory, ConfigName, Target)
Manifest = render_manifest(DestUrl, Target, "com.ibuild.Idtor", "1.0 (1.0)", "Idtor")

File.open(BuildDirectory + "/manifest.plist", "w") do |f|
  f.write(Manifest)
end
