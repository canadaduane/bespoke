# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bespoke/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name         = "bespoke"
  gem.summary      = "Bespoke does in-memory object joins using mustache templates"
  gem.description  = "Bespoke does in-memory object joins using mustache templates"
  gem.authors      = ['Duane Johnson']
  gem.email        = ['duane@instructure.com']

  gem.files = %w[bespoke.gemspec readme.md]
  gem.files += Dir.glob("lib/**/*")
  gem.files += Dir.glob("spec/**/*")

  gem.test_files    = Dir.glob("spec/**/*")
  gem.require_paths = ["lib"]
  gem.version       = Bespoke::VERSION
  gem.required_ruby_version = '>= 1.9.0'

  gem.add_development_dependency "bundler", ">= 1.0.0"
  gem.add_development_dependency "rspec", "~> 2.6"

  gem.add_dependency 'rake'
  gem.add_dependency 'docile'
  gem.add_dependency 'mustache'
end
