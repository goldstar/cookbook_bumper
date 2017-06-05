# frozen_string_literal: true

describe CookbookBumper::Metadata do
  let(:metadata) { described_class.new('spec/fixtures/cookbooks/flay/metadata.rb') }
  let(:weird_metadata) { described_class.new('spec/fixtures/cookbooks/weirdness/cookbooks/flay/metadata.rb') }

  describe '.new' do
    it 'gathers name and aliases' do
      expect(metadata.name).to eq('flay')
      expect(metadata.aliases).to eq([])
      expect(weird_metadata.name).to eq('zimmern')
      expect(weird_metadata.aliases).to eq(['flay'])
    end
  end

  describe '#respond_to_missing?' do
    it 'passes to Chef::Cookbook::Metadata' do
      expect(metadata.respond_to?(:name)).to be_truthy
      expect(metadata.respond_to?(:foobar)).to be_falsy
    end
  end

  describe '#method_missing' do
    it 'passes to Chef::Cookbook::Metadata' do
      expect(metadata.name).to eq('flay')
      expect { metadata.foobar }.to raise_error(NoMethodError)
    end
  end

  describe '#bumped?' do
    it 'tracks bumped status' do
      allow(metadata).to receive(:save)
      expect { metadata.bump }.to change { metadata.bumped? }.from(false).to(true)
    end
  end

  describe '#bump' do
    it 'bumps and saves' do
      expect(metadata.version).to receive(:bump)
      expect(metadata).to receive(:save)

      metadata.bump
    end
  end

  describe '#save' do
    it 'saves' do
      expect(metadata).to receive(:updated_contents).and_return('foo')
      expect(File).to receive(:write).with(metadata.path, 'foo')

      metadata.save
    end
  end

  describe '#updated_contents' do
    it 'updates updates the version' do
      expect(metadata.updated_contents).to match(/\s(["'])#{metadata.version}\1/)
    end
  end
end
