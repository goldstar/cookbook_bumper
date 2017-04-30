# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cookbook_bumper'

CookbookBumper.configure do |config|
  config.knife_path = File.expand_path('../../fixtures/knife.rb', __FILE__)
end

RSpec::Matchers.define :version_matching do |version|
  match { |actual| CookbookBumper::Version.new(version) == actual }
end
