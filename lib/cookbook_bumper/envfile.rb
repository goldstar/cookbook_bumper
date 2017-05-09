# frozen_string_literal: true

require 'json'
module CookbookBumper
  class EnvFile
    extend Forwardable

    attr_reader :path, :log
    def_delegators :cookbook_versions, :delete, :each, :keys, :values

    def initialize(path)
      @path = path
      @env = JSON.parse(File.read(path))
      @log = []
    end

    def [](cookbook)
      cookbook_versions[cookbook]
    end

    def []=(cookbook, version)
      cookbook_versions[cookbook] = version
    end

    def name
      @env['name']
    end

    def cookbook_versions
      @env['cookbook_versions']
    end

    def to_s
      JSON.pretty_generate(deep_sort)
    end

    def log_change(cookbook_name, old_ver, new_ver)
      action = if old_ver.nil?
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

    def update
      CookbookBumper.cookbooks.each do |cookbook|
        if cookbook.version != self[cookbook.name]
          log_change(cookbook.name, self[cookbook.name], cookbook.version)
          self[cookbook.name] = cookbook.version
        end
      end
    end

    def clean
      each do |cookbook_name, version|
        # metadata wasn't found or metadata was found using a different name
        if CookbookBumper.cookbooks[cookbook_name].nil? || CookbookBumper.cookbooks[cookbook_name].name != cookbook_name
          log_change(cookbook_name, version, nil)
          delete(cookbook_name)
        end
      end
    end

    def deep_sort(obj = @env)
      if obj.is_a?(Hash)
        obj.sort.map { |k, v| [k, deep_sort(v)] }.to_h
      else
        obj
      end
    end

    def save
      File.write(path, self)
    end
  end
end
