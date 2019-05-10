require 'auto_release_note/git_log'
include AutoReleaseNote

RSpec.describe GitLog do
  before(:all) do
    Commit = Struct.new(:message)
    Remote = Struct.new(:url)
  end

  before do
    allow(Git).to receive_message_chain(:open).and_return(git_mock)
    allow(git_mock).to receive_message_chain(:log, :between).and_return(commits)
  end
  let(:git_mock) { double }
  let(:commits) do
    [
      Commit.new("697ca9e9 Merge pull request #123 from feature/987"),
      Commit.new("05c37e69 Merge pull request #234 from fix/876"),
      Commit.new("92de9173 Merge pull request #345 from bug-fix/765"),
      Commit.new("30fde4a2 Merge pull request #456 from hotfix/654"),
      Commit.new("430cf2f4 Merge pull request #567 from release/543"),
      Commit.new("f24bd8ae Merge pull request #678 from foo"),
      Commit.new("cdf82f34 Merge pull request #789 from bar"),
      Commit.new("cdf82f34 Merge pull request #1000 from feature/1000"),
      Commit.new("cdf83f35 Merge pull request #1001 from feature/1000-2"),
      Commit.new("cdf84f35 Merge pull request #1101 from iaia/fix/1100-bug"),
      Commit.new("cdf85f35 Merge pull request #1102 from iaia/fix/1101-bug-2")
    ]
  end

  context '.new' do
    subject do
      GitLog.new("master..HEAD")
    end

    it 'mergeログがパースできる' do
      log = subject
      expect(log.logs.map {|l| l[:pull_req_id] }).to match_array \
        ['123', '234', '345', '456', '567', '678', '789', '1000', '1001', '1101', '1102']
      expect(log.logs.map {|l| l[:branch] }).to match_array \
        ['feature/987', 'fix/876', 'bug-fix/765', 'hotfix/654', 'release/543',
         'foo', 'bar', 'feature/1000', 'feature/1000-2', 'iaia/fix/1100-bug', 'iaia/fix/1101-bug-2']
    end

    it 'branch名からissue idがパースできる' do
      log = subject
      # この段階ではissue idは重複していて正しい
      expect(log.logs.map {|l| l[:issue] }).to match_array \
        ['987', '876', '765', '654', '543', '678', '789', '1000', '1000', '1100', '1101']
    end
  end

  context '#repositories' do
    subject do
      git_log.repositories
    end
    before do
      allow(git_mock).to receive(:remotes).and_return(
        [ Remote.new("https://github.com/iaia/auto_release_note.git"),
          Remote.new("https://github.com/example/auto_release_note.git") ]
      )
    end
    let(:git_log) { GitLog.new("master..HEAD") }

    it do
      expect(subject).to match_array \
        ["https://github.com/iaia/auto_release_note", "https://github.com/example/auto_release_note"]
    end
  end

  context '#repository' do
    subject do
      git_log.repository(username)
    end
    before do
      allow(git_mock).to receive(:remotes).and_return(
        [ Remote.new("https://github.com/iaia/auto_release_note.git"),
          Remote.new("https://github.com/example/auto_release_note.git") ]
      )
    end
    let(:git_log) { GitLog.new("master..HEAD") }
    let(:username) { 'iaia' }

    it do
      expect(subject).to eq "https://github.com/iaia/auto_release_note"
    end
  end
end
