require 'build'
require 'protocol/build.pb'
require 'protocol/cache.pb'

GitRepo = "/Users/indy/dev/Idtor"
ProjName = "idtor.xcodeproj"
Target = "Idtor"
ConfigName = "Release"
SDKName = "iphoneos4.3"

git_repo = GitRepoReference.new;
git_repo.GitRepo = GitRepo;

cache_ref = CacheReference.new;
#cache_ref.RepoType = Repo_Git;
cache_ref.Git = git_repo;

build_begin = BuildBegin.new;
build_begin.SourceCache = cache_ref;
build_begin.Project = ProjName;
build_begin.Target = Target;
build_begin.ConfigName = ConfigName;
build_begin.SDK = SDKName;
build_begin.Certificate = "";

build_directory = Build.gen_build_path(0, 0, 0)
dest_url = "http://arelius.com/Idtor/"

Build.init_build_directory(build_directory, build_begin.SourceCache);
Build.install_certificate(build_directory + "/Certificate.p12") # *.cer works?
project = Build.parse_project(build_directory, build_begin.Project)

build_msg = ''
ret = Build.run_xcode_build(build_directory,
                            build_begin.Project,
                            build_begin.Target,
                            build_begin.ConfigName,
                            build_begin.SDK,
                            build_msg)
#if(!ret)
  print build_msg
#end

ipa_file = Build.build_ipa(build_directory, build_begin.ConfigName, build_begin.Target)
  # We need to pull this info out of the project.
manifest = Build.render_manifest(build_directory, dest_url, build_begin.Target, build_begin.ConfigName, project)
ipa_path = Build.copy_ipa(ipa_file, 0, 0, 0)
Build.clean_build(build_directory)
if(File.exists?(ipa_path))
  print "IPA Exists\n"
else
  print "Error: IPA missing!\n"
end
FileUtils.remove(ipa_path)


