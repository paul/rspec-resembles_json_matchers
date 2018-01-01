# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/resembles_json_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-resembles_json_matchers"
  spec.version       = Rspec::ResemblesJsonMatchers::VERSION
  spec.authors       = ["Paul Sadauskas"]
  spec.email         = ["psadauskas@gmail.com"]

  spec.summary       = %q{Helpful matchers for comparing JSON documents.}
  spec.homepage      = "https://github.com/paul/rspec-resembles_json_matchers"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-state"
  spec.add_development_dependency "awesome_print"

  spec.add_runtime_dependency "rspec", ">= 2.0", "< 4.0.0.a"
  spec.add_runtime_dependency "rspec-expectations", ">= 2.0", "< 4.0.0.a"
  spec.add_runtime_dependency "rspec-support", ">= 2.0", "< 4.0.0.a"
  spec.add_runtime_dependency "activesupport", ">= 3.0" # For core extensions
end
