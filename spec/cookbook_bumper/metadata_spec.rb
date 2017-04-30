# frozen_string_literal: true

describe CookbookBumper::Metadata do
  let(:metadata) { described_class.new('spec/fixtures/cookbooks/flay/metadata.rb') }
  let(:metadata_json) { described_class.new('spec/fixtures/cookbooks/flay/metadata.json') }
  let(:weird_metadata) { described_class.new('spec/fixtures/cookbooks/weirdness/cookbooks/flay/metadata.rb') }
  let(:weird_metadata_json) { described_class.new('spec/fixtures/cookbooks/weirdness/cookbooks/flay/metadata.JSON') }

  describe '.new' do
    context 'with a standard path' do
      it 'gathers name from metadata.rb' do
        expect(metadata.name).to eq('flay')
        expect(metadata.dependencies.keys).to include('ruby')
      end

      it 'gathers name from metadata.json' do
        expect(metadata_json.name).to eq('flay')
        expect(metadata_json.dependencies.keys).to include('json')
      end
    end

    context 'with a weird path' do
      it 'gathers name from metadata.rb' do
        expect(weird_metadata.name).to eq('zimmern')
        expect(weird_metadata.dependencies).to include('ruby')
      end

      it 'gathers name from metadata.json' do
        expect(weird_metadata_json.name).to eq('zimmern')
        expect(weird_metadata_json.dependencies).to include('json')
      end
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
    it 'bumps' do
      expect(metadata.version).to receive(:bump)

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
    it 'updates the version' do
      expect(metadata.updated_contents).to match(/\s(["'])#{metadata.version}\1/)
    end
  end
end
