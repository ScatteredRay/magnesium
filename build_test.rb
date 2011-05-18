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

Build.run_build(build_begin);

