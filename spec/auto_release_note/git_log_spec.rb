require 'auto_release_note/git_log'
include AutoReleaseNote

RSpec.describe GitLog do
  context 'マージログが取得できない' do
  end

  context 'マージログが取得できる' do
    subject do
      GitLog.new(merge_log: SAMPLE_MERGE_LOG)
    end

    SAMPLE_MERGE_LOG = <<EOS
697ca9e9 Merge pull request #123 from feature/987
05c37e69 Merge pull request #234 from fix/876
92de9173 Merge pull request #345 from bug-fix/765
30fde4a2 Merge pull request #456 from hotfix/654
430cf2f4 Merge pull request #567 from release/543
f24bd8ae Merge pull request #678 from foo
cdf82f34 Merge pull request #789 from bar
EOS

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
end
