module AutoReleaseNote
  class GitLog
    attr_reader :issues, :logs

    def initialize(merge_log: nil, tag_query: nil)
      @logs = []
      @issues = []
      merge_log = `git log --merges --oneline #{tag_query} | grep 'Merge pull request #'` unless merge_log
      parse_merge_log(merge_log)
      get_issue
    end

    private
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

