# frozen_string_literal: true

describe CookbookBumper::Git do
  let(:git) { described_class.new }
  let(:diff) {[
    double(path: 'foo/bar'),
    double(path: 'foo/baz'),
    double(path: 'foo/bat')
  ]}
  let(:changed_files) {
    diff.map{ |f| File.expand_path(f.path) }
  }

  let(:config_cookbook_path) {[
    File.expand_path('cookbooks'),
    File.expand_path('cookbooks/more/cookbooks'),
    File.expand_path('other_cookbooks')
  ]}

  describe '#changed_files' do
    it 'expands paths' do
      allow(git).to receive(:diff).and_return(diff)

      expect(git.changed_files).to eq(changed_files)
    end
  end

  describe '#find_cookbook_by_file' do
    it 'finds cookbook names from a file name within' do
      file_path = File.expand_path('../../fixtures/cookbooks/flay/templates/default/template.erb', __FILE__)
      cookbook_path = File.expand_path('../../fixtures/cookbooks', __FILE__)

      expect(git.find_cookbook_by_file(file_path, cookbook_path)).to eq('flay')
    end

    it "isn't fooled by cookbook paths inside other cookbook paths" do
      file_path = File.expand_path('../../fixtures/cookbooks/foo/cookbooks/flay/templates/default/template.erb', __FILE__)
      cookbook_path = File.expand_path('../../fixtures/cookbooks', __FILE__)

      expect(git.find_cookbook_by_file(file_path, cookbook_path)).to be_nil
    end
  end

  describe '#changed_cookbooks' do
    it 'tries all paths and all files' do
      allow(git).to receive(:changed_files).and_return(changed_files)
      allow(CookbookBumper.config).to receive(:cookbook_path).and_return(config_cookbook_path)

      expect(git).to receive(:find_cookbook_by_file).with(changed_files[0], config_cookbook_path[0]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[0], config_cookbook_path[1]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[0], config_cookbook_path[2]).once

      expect(git).to receive(:find_cookbook_by_file).with(changed_files[1], config_cookbook_path[0]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[1], config_cookbook_path[1]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[1], config_cookbook_path[2]).once

      expect(git).to receive(:find_cookbook_by_file).with(changed_files[2], config_cookbook_path[0]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[2], config_cookbook_path[1]).once
      expect(git).to receive(:find_cookbook_by_file).with(changed_files[2], config_cookbook_path[2]).once

      git.changed_cookbooks
    end
  end

  describe '#bump_changed' do
    it 'bumps all changed cookbooks' do
      allow(git).to receive(:unbumped_cookbooks).and_return(['flay'])
      expect(CookbookBumper.cookbooks['flay']).to receive(:bump)

      git.bump_changed
    end
  end
end
