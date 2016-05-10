# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'findit/version'

Gem::Specification.new do |spec|
  spec.name          = "findit"
  spec.version       = Findit::VERSION
  spec.authors       = ["Denis Korobicyn"]
  spec.email         = ["deniskorobitcin@gmail.com"]

  spec.summary       = %q{Extensions for Finder classes}
  spec.homepage      = "https://github.com/abak-press/findit"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 3.1'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'will_paginate'
  spec.add_development_dependency "rspec", ">= 3.2"
  spec.add_development_dependency "rspec-rails", ">= 3.2"
  spec.add_development_dependency 'combustion', '>= 0.5'
  spec.add_development_dependency "appraisal", ">= 2.1.0"
  spec.add_development_dependency 'pry-debugger'
  spec.add_development_dependency 'shoulda-matchers', '< 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end
