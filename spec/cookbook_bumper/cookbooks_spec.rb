# frozen_string_literal: true

describe CookbookBumper::Cookbooks do
  let(:cookbooks) do
    described_class.new(['spec/fixtures/cookbooks',
                         'spec/fixtures/cookbooks/weirdness/cookbooks'])
  end

  let(:duplicate_cookbooks) do
    described_class.new(['spec/fixtures/cookbooks', 'spec/fixtures/cookbooks/duplicate/cookbooks'])
  end

  describe ':new' do
    it 'is case insensitive when finding metadata' do
      expect(cookbooks.keys).to include('florence')
    end

    it 'prefers metadata.rb over metadata.json' do
      expect(cookbooks['garten'].dependencies).to include('ruby')
    end
  end

  describe '#[]' do
    it 'retrives cookbooks by name' do
      expect(cookbooks['florence'].name).to eq('florence')
    end

    it 'raises on duplicates' do
      expect { duplicate_cookbooks['florence'] }.to raise_error(CookbookBumper::Exceptions::DuplicateName)
    end
  end
end
