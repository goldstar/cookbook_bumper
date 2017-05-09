# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cookbook_bumper/version'

Gem::Specification.new do |spec|
  spec.name          = 'cookbook_bumper'
  spec.version       = CookbookBumper::VERSION
  spec.authors       = ['Jason Scholl']
  spec.email         = ['jason.e.scholl@gmail.com']

  spec.summary       = 'Chef Cookbook Bumper'
  spec.description   = 'Automatically bump cookbook versions and environment files, and verify all changes have associated version bumps '
  spec.homepage      = 'https://github.com/jescholl/cookbook_bumper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
  spec.add_dependency 'chef', '~> 13.0'
  spec.add_dependency 'git', '~> 1.3'
end
