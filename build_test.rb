require 'build'
require 'protocol/build.pb'
require 'protocol/cache.pb'

GitRepo = File.expand_path("../mg-test");
Certificate = File.expand_path("../mg-test/Certificate.cer"); #p12??
MobileProvision = File.expand_path("../mg-test/profile.mobileprovision");
ProjName = "simple.xcodeproj"
Target = "simple"
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
build_begin.Certificate = Certificate;

Build.run_build(build_begin);
# This shouldn't be here.
Build.gen_deploy_location("profile.mobileprovision");

