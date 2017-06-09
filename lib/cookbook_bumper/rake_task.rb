# frozen_string_literal: true

require 'rake'
require 'rake/tasklib'
require 'cookbook_bumper/config'

module CookbookBumper
  class RakeTask < Rake::TaskLib
    attr_reader :name
    attr_accessor :config

    def initialize(*args)
      @name = args.shift || :bump

      desc 'Bump Cookbooks' unless ::Rake.application.last_description

      task(name, *args) do
        yield(@config = CookbookBumper::Config.new) if block_given?
        run_task
      end
    end

    def run_task
      # lazy load gem for snappier task list
      require 'cookbook_bumper'
      CookbookBumper.run(config)
    end
  end
end
