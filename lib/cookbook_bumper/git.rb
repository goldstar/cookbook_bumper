# frozen_string_literal: true

require 'git'

module CookbookBumper
  class Git
    attr_reader :diff, :status

    def initialize
      @git = ::Git.open(Dir.pwd)
      @diff = @git.diff('origin/master')
      @status = @git.status
    end

    def untracked_files
      status.select(&:untracked).map { |f| File.expand_path(f.path) }
    end

    def changed_files
      diff.map { |f| File.expand_path(f.path) }
    end

    def changed_cookbooks
      (changed_files | untracked_files).map do |file_path|
        CookbookBumper.cookbooks.find_by_path(file_path)
      end.compact.uniq
    end

    def bumped_metadata
      diff.select do |diff_file|
        CookbookBumper.config.cookbook_path.any? do |_cookbook_path|
          bumped_by_patch?(diff_file.patch)
        end
      end.map(&:path)
    end

    def bumped_by_patch?(patch)
      versions = {}
      metadata_patterns.find_all do |pattern|
        m = patch.match(pattern)
        next unless m
        name = m.names.first
        versions[name] ||= CookbookBumper::Version.new(m[name])
      end

      versions['new_version'] != versions['old_version']
    end

    def metadata_patterns
      [
        /^\+\s*version\s*['"](?<new_version>[\d\.]*)['"]/,
        /^\+.*"version":\s*"(?<new_version>[\d\.]*)"/,
        /^\-\s*version\s*['"](?<old_version>[\d\.]*)['"]/,
        /^\-.*"version":\s*"(?<old_version>[\d\.]*)"/
      ]
    end

    def bumped_cookbooks
      bumped_metadata.map do |metadata_path|
        CookbookBumper.cookbooks.find_by_path(File.expand_path(metadata_path))
      end.compact
    end

    def unbumped_cookbooks
      changed_cookbooks - bumped_cookbooks
    end

    def bump_changed(save: true)
      unbumped_cookbooks.each do |cookbook|
        cookbook.bump
        cookbook.save if save
      end
    end
  end
end
