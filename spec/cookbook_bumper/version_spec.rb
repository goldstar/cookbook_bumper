# frozen_string_literal: true

describe CookbookBumper::Version do
  let(:version) { described_class.new('1.2.3') }

  describe '#initialize' do
    it 'parses many kinds of version strings' do
      expect(described_class.new('3.2.1').to_s).to eq('3.2.1')
      expect(described_class.new('= 3.2.2').to_s).to eq('3.2.2')
      expect(described_class.new('< 3.2.3').to_s).to eq('3.2.3')
      expect(described_class.new('> 3.2.4').to_s).to eq('3.2.4')
      expect(described_class.new('<~ 3.2').to_s).to eq('3.2.0')
    end
  end

  describe '#bump' do
    it 'bumps the version' do
      expect { version.bump }.to change { version.to_s }.from('1.2.3').to('1.2.4')
    end
  end

  describe '#==' do
    it 'correctly handles strings' do
      expect(version == '1.2.3').to be_truthy
      expect(version == '1.2.3').to be_truthy
      expect(version == '1.2.4').to be_falsey
    end

    it 'correctly handles Version instances' do
      expect(version == described_class.new('1.2.3')).to be_truthy
      expect(version == described_class.new('1.2.3')).to be_truthy
      expect(version == described_class.new('1.2.4')).to be_falsey
    end
  end

  describe '#to_s' do
    it 'is the bare version' do
      expect(version.to_s).to eq('1.2.3')
    end
  end

  describe '#exact' do
    it 'provides an exact version restriction' do
      expect(version.exact).to eq('= 1.2.3')
    end
  end
end
