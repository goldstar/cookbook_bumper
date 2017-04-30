# frozen_string_literal: true

module CookbookBumper
  VERSION = '0.1.0'

  class Version
    def initialize(ver_string)
      @ver_string = ver_string
      @major, @minor, @patch = parse(ver_string)
    end

    def parse(ver_string)
      ver_string.to_s.match(/(?<major>\d+)\.(?<minor>\d+)\.?(?<patch>\d*)/) do |v|
        [v[:major], v[:minor], v[:patch]].map(&:to_i)
      end
    end

    def ==(other)
      parse(self) == parse(other)
    end

    def bump
      @patch += 1
    end

    def to_s
      [@major, @minor, @patch].compact.join('.')
    end

    def exact
      to_s.prepend('= ')
    end
  end
end
