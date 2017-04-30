# frozen_string_literal: true

describe CookbookBumper::Envs do
  let(:envs) { described_class.new(['spec/fixtures/environments']) }
  let(:log) do
    [
      ['fieri', 'Deleted', '= 0.9.0', nil],
      ['flay',     'Updated', '= 1.1.20', '= 1.1.21'],
      ['freitag',  'Bumped',  '= 0.6.7',  '= 0.6.8'],
      ['florence', 'Added',   nil,        '= 0.0.5']
    ]
  end

  describe '#update' do
    it 'cleans, adds missing, and saves all environments except exclusions' do
      expect(envs['environment_1']).to receive(:clean)
      expect(envs['environment_1']).to receive(:add_missing)
      expect(envs['environment_1']).to receive(:save)
      expect(envs['environment_2']).to receive(:clean)
      expect(envs['environment_2']).to receive(:add_missing)
      expect(envs['environment_2']).to receive(:save)
      expect(envs['environment_3']).to receive(:clean)
      expect(envs['environment_3']).to receive(:add_missing)
      expect(envs['environment_3']).to receive(:save)
      expect(envs['environment_4']).to receive(:clean)
      expect(envs['environment_4']).to receive(:add_missing)
      expect(envs['environment_4']).to receive(:save)

      expect(envs['development']).not_to receive(:clean)
      expect(envs['development']).not_to receive(:add_missing)
      expect(envs['development']).not_to receive(:save)

      envs.update
    end

    it "doesn't save when told not to" do
      expect(envs['environment_1']).to_not receive(:save)
      expect(envs['environment_2']).to_not receive(:save)
      expect(envs['environment_3']).to_not receive(:save)
      expect(envs['environment_4']).to_not receive(:save)
      expect(envs['development']).to_not receive(:save)

      envs.update(save: false)
    end
  end
end
