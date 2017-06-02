# frozen_string_literal: true

describe CookbookBumper::Envs do
  let(:envs) { described_class.new(['spec/fixtures/environments']) }
  let(:log) {[
    ['fieri',    'Deleted', '= 0.9.0',  nil],
    ['flay',     'Updated', '= 1.1.20', '= 1.1.21'],
    ['freitag',  'Bumped',  '= 0.6.7',  '= 0.6.8'],
    ['florence', 'Added',   nil,        '= 0.0.5']
  ]}

  describe '#update' do
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

  describe '#change_log' do
    it 'is evenly formatted' do
      envs.each { |env| allow(env).to receive(:log).and_return(log) }
      expect(envs.change_log.length).not_to eq(0)
      expect(envs.change_log).to all(satisfy{ |line| line.length == 63 })
    end
  end
end
