require 'rubygems'
require 'git'
require 'mustache'

BuildDirectory = "/Users/indy/dev/tmpbuilddir"
GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

DestUrl = "http://arelius.com/Idtor/"

SourceDir = Dir.pwd

begin
  Dir.mkdir(BuildDirectory)
rescue Errno::EEXIST
  # Directory exists!
end

begin
  Git.clone(GitRepo, BuildDirectory);
rescue Git::GitExecuteError
  # Git clone error.
end

# Take care of certs and provisioning profiles.
DevCert = "Certificate.p12" # *.cer works?
CertPass = "1233456789" # Perhaps we should generate this randomlly?
#system("security import #{DevCert} -k ~/Library/Keychains/login.keychain -P #{CertPass} -T /usr/bin/codesign")

# *.xcodeproj/project.pbxproj has CODE_SIGN_IDENTITY make sure those match the cert. just installed.

# Do the build.

Dir.chdir(BuildDirectory);
ret = system("xcodebuild -project #{ProjName} -target #{Target} -configuration #{ConfigName} -sdk #{SDKName}")

if(!ret)
  # build error
  # $?
end

BuildPath = BuildDirectory + "/build/#{ConfigName}-iphoneos"
AppPath = BuildPath + "/#{Target}.app"
IPAPath = BuildPath + "/#{Target}.ipa"
Payload = BuildPath + "/Payload/"

# Fail on error here.
Dir.mkdir(Payload)
FileUtils.cp_r(AppPath, Payload)

Dir.chdir(BuildPath)
ret = system("zip -r #{Target}.ipa Payload")
# fail on ret

ManifestTemplate = SourceDir + "/manifest.plist"

Mustache.template_file = ManifestTemplate
view = Mustache.new
view[:PackageUrl] = DestUrl + "#{Target}.ipa"
view[:DisplayImageUrl] = DestUrl + "Icon.png"
view[:FullImageUrl] = DestUrl + "Icon.png"

view[:BundleId] = "com.ibuild.Idtor"
view[:Version] = "1.0 (1.0)"
view[:Title] = "Idtor"

File.open(BuildPath + "/manifest.plist", "w") do |f|
  f.write(view.render)
end

