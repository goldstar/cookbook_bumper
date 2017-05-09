# frozen_string_literal: true

describe CookbookBumper::Envs do
  let(:envs) { described_class.new(['spec/fixtures/environments']) }

  describe 'update' do
    it 'cleans, updates, and saves all environments except exclusions' do
      expect(envs['environment_1']).to receive(:clean)
      expect(envs['environment_1']).to receive(:update)
      expect(envs['environment_1']).to receive(:save)
      expect(envs['environment_2']).to receive(:clean)
      expect(envs['environment_2']).to receive(:update)
      expect(envs['environment_2']).to receive(:save)
      expect(envs['environment_3']).to receive(:clean)
      expect(envs['environment_3']).to receive(:update)
      expect(envs['environment_3']).to receive(:save)
      expect(envs['environment_4']).to receive(:clean)
      expect(envs['environment_4']).to receive(:update)
      expect(envs['environment_4']).to receive(:save)

      expect(envs['development']).not_to receive(:clean)
      expect(envs['development']).not_to receive(:update)
      expect(envs['development']).not_to receive(:save)

      envs.update
    end
  end
end
