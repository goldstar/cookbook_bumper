# frozen_string_literal: true

require 'json'
module CookbookBumper
  class EnvFile
    extend Forwardable

    attr_reader :path, :log
    def_delegators :cookbook_versions, :delete, :each, :keys, :values, :[], :[]=

    def initialize(path)
      @path = path
      @environment = parse(File.read(path))
      @log = []
    end

    def name
      @environment['name']
    end

    def cookbook_versions
      @environment['cookbook_versions']
    end

    def to_s
      JSON.pretty_generate(deep_sort).concat("\n")
    end

    def log_change(cookbook_name, old_ver, new_ver)
      action = if old_ver.to_s.empty?
                 'Added'
               elsif new_ver.nil?
                 'Deleted'
               elsif CookbookBumper.cookbooks[cookbook_name].bumped?
                 'Bumped'
               else
                 'Updated'
               end
      @log << [cookbook_name, action, old_ver, new_ver]
    end

    def add_missing
      CookbookBumper.cookbooks.each do |name, cookbook|
        if cookbook.version != self[name]
          log_change(name, Version.new(self[name]), cookbook.version)
          self[name] = cookbook.version.exact
        end
      end
    end

    def clean
      each do |cookbook_name, version|
        # metadata wasn't found or metadata was found using a different name
        unless CookbookBumper.cookbooks.keys.include?(cookbook_name)
          log_change(cookbook_name, version, nil)
          delete(cookbook_name)
        end
      end
    end

    def deep_sort(obj = @environment)
      if obj.is_a?(Hash)
        obj.sort.map { |k, v| [k, deep_sort(v)] }.to_h
      else
        obj
      end
    end

    def save
      File.write(path, self)
    end

    private

    # trim out merge/rebase conflict markings and let those sections be regenerated
    def resolve_conflcits(json)
      json.gsub(/^[<>=]{5}.+/, '')
    end

    def parse(json)
      JSON.parse(resolve_conflcits(json))
    end
  end
end
