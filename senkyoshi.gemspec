# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "senkyoshi/version"
require "time"

Gem::Specification.new do |spec|
  spec.name          = "senkyoshi"
  spec.version       = Senkyoshi::VERSION
  spec.date          = Time.new.strftime("%Y-%m-%d")
  spec.authors       = "Atomic Jolt"

  spec.summary       = "Converts Blackboard zip file to Canvas Common Cartridge"
  spec.description   = "Commandline tool for converting blackboard to canvas"
  spec.homepage      = "https://github.com/atomicjolt/senkyoshi"
  spec.license       = "AGPL-3.0"
  spec.extra_rdoc_files = ["README.md"]

  spec.required_ruby_version = ">= 2.1"

  spec.files = Dir["LICENSE", "README.md", "lib/**/*", "bin/*"]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "webmock", "~> 2.1"

  [
    ["rake", ">= 11.3"],
    ["rubyzip", "~> 1.1"],
    ["nokogiri", "~> 1.8"],
    ["pandarus", "~> 0.6"],
    ["activesupport", ">= 4.2"],
    ["rest-client", "~> 2.0"],
    ["jwt", "~> 2.1"],
  ].each { |d| spec.add_runtime_dependency(*d) }
end
