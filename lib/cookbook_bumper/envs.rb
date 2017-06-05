# frozen_string_literal: true

require 'terminal-table'

module CookbookBumper
  class Envs
    include Enumerable
    def initialize(environment_path)
      @files = environment_path.map { |e| Dir[File.join(e, '*')] }.flatten
      @envs = @files.map { |file| CookbookBumper::EnvFile.new(file) }
      @change_log = []
      Terminal::Table::Style.defaults = { border_top: false, border_bottom: false, border_y: '', border_i: '' }
    end

    def [](env_name)
      @envs.select { |e| e.name == env_name }.tap do |envs|
        raise "multiple environments named #{env_name}" if envs.length > 1
      end.first
    end

    def each
      @envs.each do |env|
        yield env
      end
    end

    def update
      reject { |e| CookbookBumper.config.exclude_environments.include?(e.name) }.each do |env|
        env.clean
        env.update
        env.save
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
