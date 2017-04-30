# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'
require 'cookbook_bumper/config'

module CookbookBumper
  class RakeTask < Rake::TaskLib
    attr_reader :name, :args

    def initialize(*args, &block)
      @name = args.shift || :bump
      @args = *args
      @block = block

      create_task(name, 'Bump Cookbooks', :bump)
      namespace task_namespace do
        create_task({ verify: task_dependencies }, 'Verify everything has been bumped', :verify)
      end
    end

    def config
      @config ||= CookbookBumper::Config.new
    end

    def task_namespace
      if name.respond_to?(:keys)
        name.keys.first
      else
        name
      end
    end

    def task_dependencies
      if name.respond_to?(:keys)
        name[task_namespace]
      else
        []
      end
    end

    def create_task(name, description, task)
      desc description unless ::Rake.application.last_description

      task(name, *args) do
        @block&.call(config)
        run_task(task)
      end
    end

    def run_task(task)
      # lazy load gem for snappier task list
      require 'cookbook_bumper'
      CookbookBumper.send(task, config)
    end
  end
end
