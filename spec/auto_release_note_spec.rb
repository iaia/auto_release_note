RSpec.describe AutoReleaseNote do
  it "has a version number" do
    expect(AutoReleaseNote::VERSION).not_to be nil
  end

  context '.execute' do
    subject do
      AutoReleaseNote.execute(username: username)
    end
    before do
      mock = double
      allow(AutoReleaseNote::GitLog).to receive(:new).and_return(mock)
      allow(mock).to receive(:repository).and_return("https://github.com/iaia/auto_release_note")
      allow(mock).to receive(:logs).and_return(
        [
          { issue: '987' },
          { issue: '876' },
          { issue: '765' },
          { issue: '654' },
          { issue: '543' },
          { issue: '678' },
          { issue: '789' }
        ]
      )
    end

    let(:username) { 'iaia' }

    it do
      release_note = subject

      result = ['987', '876', '765', '654', '543', '678', '789'].map do |issue|
        "https://github.com/#{username}/auto_release_note/issues/#{issue}"
      end

      expect(release_note).to match_array result
    end
  end
end
