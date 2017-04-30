# frozen_string_literal: true

module CookbookBumper
  class Cookbooks
    include Enumerable
    extend Forwardable

    def_delegators :@metadata, :[], :each, :keys, :values

    def initialize(cookbook_path)
      @cookbook_path = cookbook_path
      @metadata = {}
      collect_metadata
    end

    def collect_metadata
      metadata_files.map do |f|
        metadata = CookbookBumper::Metadata.new(f)
        if @metadata[metadata.name]
          raise CookbookBumper::Exceptions::DuplicateName, "cookbook #{metadata.name} found in multiple locations"
        end
        @metadata[metadata.name] = metadata
      end
    end

    def find_by_path(cookbook_path)
      values.select { |c| cookbook_path.start_with?(File.dirname(c.path)) }.first
    end

    def metadata_files
      # Dir.glob won't match insensitively on linux without a wildcard or character set in the filename
      files = @cookbook_path.map { |d| Dir.glob(File.join(d, '*', '[Mm]etadata.{json,rb}'), File::FNM_CASEFOLD) }.flatten
      # prefer metadata.rb over metadata.json if both exist
      files.delete_if { |file| file.start_with?(*duplicated_paths(files)) && file.match(/\.json$/i) }
    end

    def duplicated_paths(files)
      dirs = files.map { |file| File.dirname(file) }
      dirs.find_all { |dir| dirs.count(dir) > 1 }.uniq
    end
  end
end
