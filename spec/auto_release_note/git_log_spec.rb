require 'auto_release_note/git_log'
include AutoReleaseNote

RSpec.describe GitLog do
  before do
    allow(Git).to receive_message_chain(:open).and_return(git_mock)
    allow(git_mock).to receive_message_chain(:log, :between).and_return(SAMPLE_MERGE_LOG)
  end
  let(:git_mock) { double }

  SAMPLE_MERGE_LOG = <<EOS
697ca9e9 Merge pull request #123 from feature/987
05c37e69 Merge pull request #234 from fix/876
92de9173 Merge pull request #345 from bug-fix/765
30fde4a2 Merge pull request #456 from hotfix/654
430cf2f4 Merge pull request #567 from release/543
f24bd8ae Merge pull request #678 from foo
cdf82f34 Merge pull request #789 from bar
EOS

  context '.new' do
    subject do
      GitLog.new("master..HEAD")
    end

    it 'mergeログがパースできる' do
      log = subject
      expect(log.logs.map {|l| l[:pull_req_id] }).to match_array \
        ['123', '234', '345', '456', '567', '678', '789']
      expect(log.logs.map {|l| l[:branch] }).to match_array \
        ['feature/987', 'fix/876', 'bug-fix/765', 'hotfix/654', 'release/543', 'foo', 'bar']
    end

    it 'branch名からissue idがパースできる' do
      log = subject
      expect(log.logs.map {|l| l[:issue] }).to match_array \
        ['987', '876', '765', '654', '543', '678', '789']
    end
  end

  context '#repositories' do
    subject do
      git_log.repositories
    end
    before do
      Remote = Struct.new(:url)
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
      Remote = Struct.new(:url)
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
