# frozen_string_literal: true

module CookbookBumper
  class Cookbooks
    include Enumerable
    attr_accessor :aliases
    def initialize(cookbook_path)
      @files = cookbook_path.map { |c| Dir[File.join(c, '*', 'metadata.rb')] }.flatten
      @metadata = @files.map do |f|
        CookbookBumper::Metadata.new(f)
      end
    end

    def [](cookbook)
      @metadata.select { |m| m.name == cookbook || m.aliases.include?(cookbook) }.tap do |cookbooks|
        raise "multiple cookbooks named #{cookbook}" if cookbooks.length > 1
      end.first
    end

    def bump_modified
      CookbookBumper.git.unbumped_cookbooks.each do |c|
        CookbookBumper.cookbooks[c].bump
      end
    end

    def each
      @metadata.each do |md|
        yield md
      end
    end
  end
end
