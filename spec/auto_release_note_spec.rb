RSpec.describe AutoReleaseNote do
  it "has a version number" do
    expect(AutoReleaseNote::VERSION).not_to be nil
  end

  context do
    subject do
      AutoReleaseNote.execute(username: username, merge_log: SAMPLE_MERGE_LOG)
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
    let(:username) { 'iaia' }

    it do
      release_note = subject

      result = ['987', '876', '765', '654', '543', '678', '789'].map do |issue|
        "https://github.com/#{username}/#{issue}"
      end

      expect(release_note).to match_array result
    end
  end
end
