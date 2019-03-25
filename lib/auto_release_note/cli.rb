require 'auto_release_note'
require 'thor'

module AutoReleaseNote
  class CLI < Thor
    default_task :execute

    desc 'execute username tagquery', 'execute desc'
    def execute(username, tag_query)
      puts AutoReleaseNote.execute(username: username, tag_query: tag_query)
    end

    desc 'version', 'version'
    def version
      puts AutoReleaseNote::VERSION
    end
  end
end
