# frozen_string_literal: true

describe CookbookBumper::Config do
  let(:config) { described_class.new }

  describe '#knife_path=' do
    it 'reloads the config' do
      expect(config).to receive(:read_chef_config).once
      config.knife_path = '/foo/bar'
    end
  end

  describe '#cookbook_path' do
    it 'expands the path(s)' do
      expect(config.cookbook_path).to be_a(Array)
      expect(config.cookbook_path).to all(match(%r{^/}))
    end
  end

  describe '#environment_path' do
    it 'expands the path(s)' do
      expect(config.environment_path).to be_a(Array)
      expect(config.environment_path).to all(match(%r{^/}))
    end
  end

  describe '#read_chef_config' do
    it 'warns on errors' do
      allow(Chef::Config).to receive(:from_file).and_raise('this is an error')
      expect { config.read_chef_config }.to_not raise_error
    end
  end
end
