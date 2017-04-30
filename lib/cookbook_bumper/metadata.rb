# frozen_string_literal: true

require 'chef/cookbook/metadata'

module CookbookBumper
  class Metadata
    attr_reader :path

    def initialize(path)
      @path = path
      @metadata = ::Chef::Cookbook::Metadata.new
      from_file(@path)
    end

    def from_file(path)
      case path
      when /\.json$/i
        @metadata.from_json(File.read(path))
      when /\.rb$/i
        @metadata.from_file(path)
      else
        raise CookbookBumper::Exceptions::MetadataNotFound
      end
    end

    def version
      @version ||= CookbookBumper::Version.new(@metadata.version)
    end

    def bumped?
      version != @metadata.version
    end

    def bump
      version.bump
    end

    def updated_contents
      File.read(path).sub(/^\s*version.*/) do |version_line|
        version_line.sub(/[\d\.]+/, @metadata.version => version)
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
