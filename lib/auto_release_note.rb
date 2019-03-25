require "auto_release_note/version"
require "auto_release_note/git_log"
require "auto_release_note/cli"

module AutoReleaseNote
  class << self
    def execute(username:, merge_log: nil, tag_query: nil)
      log = AutoReleaseNote::GitLog.new(merge_log: merge_log, tag_query: tag_query)
      links = log.logs.map {|l| l[:issue].to_i }.sort.map do |issue|
        "https://github.com/#{username}/#{issue}"
      end
    end
  end
end
