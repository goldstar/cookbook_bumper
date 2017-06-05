# frozen_string_literal: true

describe CookbookBumper::Cookbooks do
  let(:cookbooks) do
    described_class.new(['spec/fixtures/cookbooks',
                         'spec/fixtures/cookbooks/weirdness/cookbooks'])
  end

  describe '#bump_modified' do
    it 'bumps modified cookbooks' do
      allow(CookbookBumper.git).to receive(:unbumped_cookbooks).and_return(%w[freitag florence])
      expect(cookbooks['freitag']).to receive(:bump)
      expect(cookbooks['florence']).to receive(:bump)

      cookbooks.bump_modified
    end
  end

  describe '#[]' do
    it 'retrives cookbooks by name' do
      expect(cookbooks['florence'].name).to eq('florence')
    end

    it 'retrives cookbooks by alias' do
      expect(cookbooks['chef-freitag'].name).to eq('freitag')
    end

    it 'raises on duplicates' do
      expect { cookbooks['flay'].name }.to raise_error(RuntimeError)
    end
  end
end
