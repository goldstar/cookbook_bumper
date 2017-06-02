# frozen_string_literal: true

require 'chef/cookbook/metadata'

module CookbookBumper
  class Metadata
    attr_reader :aliases, :path, :version

    def initialize(path)
      @path = path
      @aliases = []
      @metadata = parse(path)
      @version = CookbookBumper::Version.new(@metadata.version)
    end

    def parse(path)
      metadata = Chef::Cookbook::Metadata.new.tap { |m| m.from_file(path); m } # rubocop:disable Style/Semicolon
      path.match(%r{/(?<cookbook_dir>[^/]+)/metadata\.rb$}) do |m|
        @aliases |= [m[:cookbook_dir]] if metadata.name != m[:cookbook_dir]
      end
      metadata
    end

    def bumped?
      @version != @metadata.version
    end

    def bump
      version.bump
      save
    end

    def updated_contents
      File.read(path).sub(/^\s*version.*/) do |version_line|
        version_line.sub(/[\d\.]+/, @metadata.version => @version)
      end
    end

    def save
      File.write(path, updated_contents)
    end

    def method_missing(method_sym, *args, &block)
      if respond_to?(method_sym)
        @metadata.send(method_sym, *args, &block)
      else
        puts "Couldn't find method #{method_sym}"
        super
      end
    end

    def respond_to_missing?(method_sym, include_private = false)
      @metadata.respond_to?(method_sym) || super
    end
  end
end
