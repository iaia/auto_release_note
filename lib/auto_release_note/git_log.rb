require 'git'

module AutoReleaseNote
  class GitLog
    attr_reader :issues, :logs

    def initialize(tag_query)
      @logs = []
      @issues = []
      @git = Git.open(Dir.pwd)
      parse_merge_log(get_merge_log(tag_query))
      get_issue
    end

    def repositories
      @git.remotes.map {|remote| remote.url.gsub(/.git$/, '') }
    end

    private
    def get_merge_log(tag_query)
      merge_log ||= @git.log.between(tag_query.split("..")[0], tag_query.split("..")[1]) # `git log --merges --oneline #{tag_query} | grep 'Merge pull request #'`
    end

    def parse_merge_log(merge_log)
      merge_log.each_line do |line|
        logs << { pull_req_id: get_pull_req_id(line), branch: get_branch_name(line), issue: nil }
      end
      logs.compact!
    end

    def get_pull_req_id(log)
      log.match(/Merge pull request #(.+) from .*/)[1]
    end

    def get_branch_name(log)
      log.match(/Merge pull request .+ from (.+)/)[1]
    end

    def get_issue
      get_issue_id_by_branch_name
      substitute_pull_req_for_issue
    end

    def get_issue_id_by_branch_name
      @logs.each do |log|
        id = log[:branch].match(/\D*(\d+)\D*/)
        log[:issue] = id[1] if id
      end
    end

    def substitute_pull_req_for_issue
      @logs.each do |log|
        log[:issue] = log[:pull_req_id] unless log[:issue]
      end
    end
  end
end

