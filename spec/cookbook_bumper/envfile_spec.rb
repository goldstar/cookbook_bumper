# frozen_string_literal: true

describe CookbookBumper::EnvFile do
  let(:envfile) { described_class.new('spec/fixtures/environments/environment_1.json') }
  let(:cookbooks) { CookbookBumper::Cookbooks.new(['spec/fixtures/cookbooks']) }


  describe '#name' do
    it 'is the name' do
      expect(envfile.name).to eq('environment_1')
    end
  end

  describe '#[]' do
    it 'gets cookbook versions' do
      expect(envfile['flay']).to eq('= 1.1.20')
    end
  end

  describe '#[]=' do
    it 'sets cookbook versions' do
      expect{envfile['fieri'] = '1.2.3'}.to change{envfile['fieri']}.from('= 0.9.0').to('1.2.3')
    end
  end

  describe '#log_change' do
    it 'collects logs' do
      allow(CookbookBumper).to receive(:cookbooks).and_return('fieri' => double(bumped?: true))
      expect{envfile.log_change('fieri', 'old', 'new')}.to change{envfile.log.length}.from(0).to(1)
      expect{envfile.log_change('fieri', 'old', 'new')}.to change{envfile.log.length}.from(1).to(2)
    end

    it 'detects added logs' do
      expect{envfile.log_change('fieri', nil, 'new')}.to change{envfile.log}.from([]).to([['fieri', 'Added', nil, 'new']])
    end

    it 'detects deleted logs' do
      expect{envfile.log_change('fieri', 'old', nil)}.to change{envfile.log}.from([]).to([['fieri', 'Deleted', 'old', nil]])
    end

    it 'detects bumped logs' do
      allow(CookbookBumper).to receive(:cookbooks).and_return('fieri' => double(bumped?: true))
      expect{envfile.log_change('fieri', 'old', 'new')}.to change{envfile.log}.from([]).to([['fieri', 'Bumped', 'old', 'new']])
    end

    it 'detects updated logs' do
      allow(CookbookBumper).to receive(:cookbooks).and_return('fieri' => double(bumped?: false))
      expect{envfile.log_change('fieri', 'old', 'new')}.to change{envfile.log}.from([]).to([['fieri', 'Updated', 'old', 'new']])
    end
  end

  describe '#to_s' do
    it 'returns a string' do
      expect(envfile.to_s).to be_a(String)
    end
  end

  describe '#update' do
    it 'updates from metadata' do
      allow(CookbookBumper).to receive(:cookbooks).and_return(cookbooks)
      expect{envfile.update}.to change{envfile['flay'].to_s}.from('= 1.1.20').to('= 1.1.21')
    end

    it 'logs changes' do
      allow(CookbookBumper).to receive(:cookbooks).and_return(cookbooks)
      expect(envfile).to receive(:log_change).once.with('flay', '= 1.1.20', version_matching('1.1.21'))
      envfile.update
    end
  end

  describe '#clean' do
    it 'deletes entries without cookbooks' do
      allow(CookbookBumper).to receive(:cookbooks).and_return(cookbooks)
      expect{envfile.clean}.to change{envfile.keys}.from(
        ['florence', 'flay', 'fieri', 'freitag']
      ).to(
        ['florence', 'flay', 'freitag']
      )
    end

    it 'logs changes' do
      allow(CookbookBumper).to receive(:cookbooks).and_return(cookbooks)
      expect(envfile).to receive(:log_change).once.with('fieri', '= 0.9.0', nil)
      envfile.clean
    end
  end

  describe '#depp_sort' do
    let(:sorted)   { '{"1":"one","2":{"a":"apple","b":"bear"},"3":["c","d","b","a"]}' }
    let(:unsorted) { '{"2":{"b":"bear","a":"apple"},"3":["c","d","b","a"],"1":"one"}' }
    it 'sorts a hash recursively' do
      expect(envfile.deep_sort(JSON.parse(unsorted)).to_json).to eq(sorted)
    end
  end

end
