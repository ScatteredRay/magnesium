require 'rubygems'
require 'git'
require 'protocol/cache.pb'

module Cache_Git extend self
  def run_cache(repo, dest)
    #assert(repo.RepoType == Git);
    FileUtils.mkpath(dest);

    begin
      Git.clone(repo.Git.GitRepo, dest);
    rescue Git::GitExecuteError
      # Git clone error.
      #Dir.rmdir(build_directory); # Do this recursive
      #client_error("...") #TODO: Error handling
    end
  end
end
