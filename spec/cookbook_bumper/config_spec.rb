# frozen_string_literal: true

describe CookbookBumper::Config do
  let(:config) do
    described_class.new do |config|
      config.knife_path = File.expand_path('../../fixtures/knife.rb', __FILE__)
    end
  end

  describe '#cookbook_path' do
    it 'expands the path(s)' do
      expect(config.cookbook_path).to be_a(Array)
      expect(config.cookbook_path).to all(match(%r{^/}))
    end

    it 'loads the config the first time only' do
      expect(config).to receive(:read_chef_config).and_call_original.once
      config.cookbook_path
      config.cookbook_path
    end
  end

  describe '#environment_path' do
    it 'expands the path(s)' do
      expect(config.environment_path).to be_a(Array)
      expect(config.environment_path).to all(match(%r{^/}))
    end

    it 'loads the config the first time only' do
      expect(config).to receive(:read_chef_config).and_call_original.once
      config.environment_path
      config.environment_path
    end
  end
end
