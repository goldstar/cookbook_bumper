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
  module Exceptions
    class DuplicateName < RuntimeError; end
    class MetadataNotFound < RuntimeError; end
  end

  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  def self.cookbooks
    @cookbooks ||= Cookbooks.new(config.cookbook_path)
  end

  def self.bump(override_config = nil)
    @config = override_config if override_config
    envs = Envs.new(config.environment_path)
    git = Git.new

    git.bump_changed
    envs.update

    puts envs.change_log
  end

  def self.verify(override_config = nil) # rubocop:disable Metrics/AbcSize
    @config = override_config if override_config
    envs = Envs.new(config.environment_path)
    git = Git.new

    git.bump_changed(save: false)
    envs.update(save: false)

    puts "The following cookbooks need to be bumped:\n* #{git.unbumped_cookbooks.map(&:name).join("\n* ")}\n" unless git.unbumped_cookbooks.empty?
    puts envs.change_log
    exit envs.map(&:log).map(&:length).inject(git.unbumped_cookbooks.length, &:+)
  end
end
