# frozen_string_literal: true

require 'git'

module CookbookBumper
  class Git
    attr_reader :diff

    def initialize
      @git = ::Git.open(Dir.pwd)
      @diff = @git.diff('origin/master')
    end

    def changed_files
      diff.map { |f| File.expand_path(f.path) }
    end

    def changed_cookbooks
      changed_files.map do |changed_file_path|
        CookbookBumper.config.cookbook_path.map do |cookbook_path|
          find_cookbook_by_file(changed_file_path, cookbook_path)
        end.compact
      end.flatten.uniq
    end

    def find_cookbook_by_file(changed_file_path, cookbook_path)
      changed_file_path.match(%r{^#{cookbook_path}/(?<cookbook>[^\/]+)}) do |m|
        # ignore matches without metadata.rb, they are not cookbooks
        if File.exist?(File.join(cookbook_path, m[:cookbook], 'metadata.rb'))
          CookbookBumper.cookbooks[m[:cookbook]].name
        end
      end
    end

    def bumped_metadata
      diff.select do |f|
        CookbookBumper.config.cookbook_path.any? do |cookbook_path|
          File.expand_path(f.path) =~ %r{#{cookbook_path}/[^/]+/metadata\.rb} &&
            f.patch =~ /^\+version/
        end
      end.map(&:path)
    end

    def bumped_cookbooks
      bumped_metadata.map do |metadata_path|
        metadata_path.match(%r{(?<cookbook>[^/]+)/metadata\.rb}) do |m|
          CookbookBumper.cookbooks[m[:cookbook]].name
        end
      end
    end

    def unbumped_cookbooks
      changed_cookbooks - bumped_cookbooks
    end

    def bump_changed
      unbumped_cookbooks.each do |cookbook_name|
        CookbookBumper.cookbooks[cookbook_name].bump
      end
    end
  end
end
