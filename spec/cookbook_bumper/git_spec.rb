# frozen_string_literal: true

describe CookbookBumper::Git do
  let(:git) { described_class.new }

  let(:diff) do
    [
      double(
        path: 'spec/fixtures/cookbooks/flay/metadata.rb',
        patch: <<~EOT
            foo 'something'
          - version '1.2.3'
          + version   '1.2.3'
            bar 'something'
        EOT
      ),
      double(
        path: 'spec/fixtures/cookbooks/florence/MetADatA.Rb',
        patch: <<~EOT
            foo 'something'
          - version '1.2.3'
          + version   '1.2.4'
            bar 'something'
        EOT
      ),
      double(
        path: 'spec/fixtures/cookbooks/bourdain/metadata.json',
        patch: <<~EOT
          [
            "foo": "something",
          - "version": "1.2.3",
          + "version": "1.2.4"
            "bar": "something"
          ]
        EOT
      ),
      double(
        path: 'spec/fixtures/cookbooks/chef-freitag/MetADatA.jsON',
        patch: <<~EOT
          -[ "foo": "something", "version": "1.2.3" "bar": "something" ]
          +[ "foo": "something", "version": "1.2.4" "bar": "something" ]
        EOT
      )
    ]
  end
  let(:status) do
    [
      double(path: 'spec/fixtures/cookbooks/flay/UNTRACKED',         untracked: true),
      double(path: 'spec/fixtures/cookbooks/chef-freitag/UNTRACKED', untracked: true),
      double(path: 'spec/fixtures/cookbooks/florence/TRACKED',       untracked: nil)
    ]
  end

  let(:config_cookbook_path) do
    [
      File.expand_path('spec/fixtures/cookbooks'),
      File.expand_path('spec/fixturescookbooks/weirdness/cookbooks')
    ]
  end

  describe '#changed_files' do
    it 'expands paths' do
      allow(git).to receive(:diff).and_return(diff)

      expect(git.changed_files).to all(start_with('/'))
    end
  end

  describe '#untracked_cookbooks' do
    it 'expands paths' do
      allow(git).to receive(:status).and_return(status)

      expect(git.untracked_files).to all(start_with('/'))
    end

    it 'only returns untracked files' do
      allow(git).to receive(:status).and_return(status)

      expect(git.untracked_files).to all(include('UNTRACKED'))
    end
  end

  describe '#changed_cookbooks' do
    it 'looks at changed and untracked cookbooks' do
      allow(git).to receive(:diff).and_return(diff)
      allow(git).to receive(:status).and_return(status)
      allow(CookbookBumper.config).to receive(:cookbook_path).and_return(config_cookbook_path)

      expect(git.changed_cookbooks.map(&:name)).to contain_exactly('flay', 'freitag', 'florence', 'bourdain')
    end
  end

  describe '#bump_changed' do
    it 'bumps all changed cookbooks' do
      allow(git).to receive(:diff).and_return(diff)
      expect(CookbookBumper.cookbooks['flay']).to receive(:bump)

      git.bump_changed
    end

    it 'saves by default' do
      allow(git).to receive(:diff).and_return(diff)
      expect(CookbookBumper.cookbooks['flay']).to receive(:bump)
      expect(CookbookBumper.cookbooks['flay']).to receive(:save)

      git.bump_changed
    end

    it "doesn't save when told not to" do
      allow(git).to receive(:diff).and_return(diff)
      expect(CookbookBumper.cookbooks['flay']).to receive(:bump)
      expect(CookbookBumper.cookbooks['flay']).to_not receive(:save)

      git.bump_changed(save: false)
    end
  end

  describe '#bumped_metadata' do
    it "isn't fooled by whitespace changes on version line" do
      allow(git).to receive(:diff).and_return(diff)
      allow(CookbookBumper.config).to receive(:cookbook_path).and_return(config_cookbook_path)

      expect(git.bumped_metadata).not_to include('spec/fixtures/cookbooks/flay/metadata.rb')
      expect(git.bumped_metadata).to include('spec/fixtures/cookbooks/florence/MetADatA.Rb')
    end
  end

  describe '#bumped_cookbooks' do
    it 'returns Metadata' do
      allow(git).to receive(:diff).and_return(diff)
      allow(CookbookBumper.config).to receive(:cookbook_path).and_return(config_cookbook_path)

      expect(git.bumped_cookbooks).to all(be_an(CookbookBumper::Metadata))
    end
  end
end
