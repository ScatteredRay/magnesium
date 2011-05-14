require 'rubygems'
require 'git'
require 'protocol/cache.pb'

module Cache_Git extend self
  def cache_get(repo, dest)
    #assert(repo.RepoType == Git);
    begin
      Git.clone(repo.Git.GitRepo, dest);
    rescue Git::GitExecuteError
      # Git clone error.
      #Dir.rmdir(build_directory); # Do this recursive
      #client_error("...") #TODO: Error handling
    end
  end
end
