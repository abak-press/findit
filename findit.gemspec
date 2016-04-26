# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'findit/version'

Gem::Specification.new do |spec|
  spec.name          = "findit"
  spec.version       = Findit::VERSION
  spec.authors       = ["Denis Korobicyn"]
  spec.email         = ["deniskorobitcin@gmail.com"]

  spec.summary       = %q{Finder patther}
  spec.description   = %q{Fix you fat controller by moving all search logic to finder class}
  spec.homepage      = "https://github.com/abak-press/findit"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rails', '>= 3.1'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'combustion', '~> 0.5'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'pry-debugger'
  spec.add_development_dependency 'shoulda-matchers', '< 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
end
