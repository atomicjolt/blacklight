# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "blacklight/version"
require "time"

Gem::Specification.new do |spec|
  spec.name          = "blacklight"
  spec.version       = Blacklight::VERSION
  spec.date        	 = Time.new.strftime("%Y-%m-%d")
  spec.authors       = "Atomic Jolt"

  spec.summary       = "Converts Blackboard zip file to Canvas Common Cartridge"
  spec.description   = "Commandline tool for converting blackboard to canvas"
  spec.homepage      = "https://github.com/atomicjolt/blacklight"
  spec.license       = "MIT"
  spec.extra_rdoc_files = ["README.md"]

  spec.files         = `git ls-files -z`.split("\x0").
    reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "minitest", "~> 5.9"

  spec.metadata["allowed_push_host"] = "https://github.com/atomicjolt/"

  [
    ["rake", "~> 11.3"],
    ["rubyzip", "~> 1.1"],
    ["nokogiri", "~> 1.6.6"],
    ["fileutils", "~> 0.7"],
    ["require_all", "~> 1.3.3"],
  ].each { |d| spec.add_runtime_dependency(*d) }
end
