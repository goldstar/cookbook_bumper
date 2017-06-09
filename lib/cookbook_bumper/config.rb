# frozen_string_literal: true

module CookbookBumper
  class Config
    attr_accessor :repo_root, :exclude_environments, :knife_path
    attr_writer :cookbook_path, :environment_path
    def initialize
      @exclude_environments = %w[development]
      @knife_path = File.expand_path('.chef/knife.rb')
      @repo_root = File.expand_path('.')
      yield(self) if block_given?
    end

    def cookbook_path
      @cookbook_path || Array(fetch_chef_config(:cookbook_path)).map { |p| File.expand_path(p) }
    end

    def environment_path
      @environment_path || Array(fetch_chef_config(:environment_path)).map { |p| File.expand_path(p) }
    end

    def fetch_chef_config(config_name)
      read_chef_config unless config_already_read?
      Chef::Config.send(config_name)
    end

    def config_already_read?
      @knife_path == @knife_path_read
    end

    def read_chef_config
      Chef::Config.from_file(@knife_path)
      @knife_path_read = @knife_path
    end
  end
end
