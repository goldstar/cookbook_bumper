# frozen_string_literal: true

module CookbookBumper
  class Envs
    include Enumerable
    def initialize(environment_path)
      @files = environment_path.map { |e| Dir[File.join(e, '*')] }.flatten
      @envs = @files.map { |file| CookbookBumper::EnvFile.new(file) }
      @change_log = []
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
      [].tap do |log|
        each do |env|
          next if env.log.empty?
          log << ' ' * 63
          log << format("%-20s%10s %10s %10s %10s", env.name, 'Cookbook', 'Action', 'Old Ver', 'New Ver')
          log << '-' * 63
          env.log.each do |cookbook, action, old_ver, new_ver|
            log << format('%30s %10s %10s %10s', cookbook, action, old_ver, new_ver)
          end
        end
      end
    end
  end
end
