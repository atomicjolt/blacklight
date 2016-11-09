# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blacklight/version'
require 'time'

Gem::Specification.new do |spec|
  spec.name          = "blacklight"
  spec.version       = Blacklight::VERSION
  spec.date        	 = Time.new.strftime("%Y-%m-%d")
  spec.authors       = "Atomic Jolt"

  spec.summary       = "Converts Blackboard zip file to Canvas Common Cartridge"
  spec.description   = "Commandline tool that convert blackboard course export to canvas imscc file"
  spec.homepage      = "https://github.com/atomicjolt/blacklight"
  spec.license       = "MIT"
  spec.extra_rdoc_files = ['README.md']

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.metadata['allowed_push_host'] = 'https://github.com/atomicjolt/'

end
