# frozen_string_literal: true

module CookbookBumper
  class Config
    attr_accessor :repo_root, :exclude_environments
    attr_writer :cookbook_path, :environment_path
    attr_reader :knife_path
    def initialize
      @exclude_environments = %w[development]
      @knife_path = File.expand_path('.chef/knife.rb')
      @repo_root = File.expand_path('.')
      read_chef_config
    end

    def knife_path=(path)
      @knife_path = path
      read_chef_config
      @knife_path
    end

    def cookbook_path
      @cookbook_path ||= Array(Chef::Config.cookbook_path).map { |p| File.expand_path(p) }
    end

    def environment_path
      @environment_path ||= Array(Chef::Config.environment_path).map { |p| File.expand_path(p) }
    end

    def read_chef_config
      Chef::Config.from_file(@knife_path)
      @cookbook_path = nil
      @environment_path = nil
    rescue => e
      warn e
    end
  end
end
