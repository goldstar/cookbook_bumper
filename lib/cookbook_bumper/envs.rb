# frozen_string_literal: true

require 'terminal-table'

module CookbookBumper
  class Envs
    include Enumerable
    extend Forwardable

    attr_accessor :all_envs
    def_delegators :envs, :each

    def initialize(environment_path)
      @files = environment_path.map { |e| Dir[File.join(e, '*')] }.flatten
      @all_envs = @files.map { |file| CookbookBumper::EnvFile.new(file) }
      @change_log = []
      Terminal::Table::Style.defaults = { border_top: false, border_bottom: false, border_y: '', border_i: '' }
    end

    def [](env_name)
      all_envs.select { |e| e.name == env_name }.tap do |matching_envs|
        raise CookbookBumper::Exceptions::DuplicateName, "multiple environments named #{env_name}" if matching_envs.length > 1
      end.first
    end

    def envs
      @envs ||= @all_envs.reject { |e| CookbookBumper.config.exclude_environments.include?(e.name) }
    end

    def update(save: true)
      each do |env|
        env.clean
        env.add_missing
        env.save if save
      end
    end

    def change_log
      reject { |env| env.log.empty? }.map do |env|
        Terminal::Table.new do |t|
          t.title = env.name
          t.headings = ['Cookbook', 'Action', 'Old Ver', 'New Ver']
          t.rows = env.log
        end
      end.join("\n\n")
    end
  end
end
