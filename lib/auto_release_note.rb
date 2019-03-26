require "auto_release_note/version"
require "auto_release_note/git_log"
require "auto_release_note/cli"

module AutoReleaseNote
  class << self
    def execute(username:, tag_query: nil)
      log = AutoReleaseNote::GitLog.new(tag_query: tag_query)
      repository = log.repositories.first
      links = log.logs.map {|l| l[:issue].to_i }.sort.map do |issue|
        "#{repository}/#{issue}"
      end
    end
  end
end
