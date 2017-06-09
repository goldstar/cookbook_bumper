# frozen_string_literal: true

require 'cookbook_bumper/version'
require 'cookbook_bumper/envs'
require 'cookbook_bumper/envfile'
require 'cookbook_bumper/git'
require 'cookbook_bumper/metadata'
require 'cookbook_bumper/cookbooks'
require 'cookbook_bumper/config'
require 'chef'

module CookbookBumper
  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  def self.cookbooks
    @cookbooks ||= Cookbooks.new(config.cookbook_path)
  end

  def self.run(override_config = nil)
    @config = override_config if override_config
    envs = Envs.new(config.environment_path)
    git = Git.new

    git.bump_changed
    envs.update
    puts envs.change_log
  end
end
