# frozen_string_literal: true

describe CookbookBumper::Cookbooks do
  let(:cookbooks) do
    described_class.new(['spec/fixtures/cookbooks',
                         'spec/fixtures/cookbooks/weirdness/cookbooks'])
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
