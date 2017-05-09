# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cookbook_bumper'

RSpec::Matchers.define :version_matching do |version|
  match { |actual| CookbookBumper::Version.new(version) == actual }
end
