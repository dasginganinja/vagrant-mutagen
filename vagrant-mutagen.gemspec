# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-mutagen/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-mutagen'
  spec.version       = VagrantPlugins::Mutagen::VERSION
  spec.authors       = ['Tom Donahue']
  spec.email         = ['dasginganinja@gmail.com']
  spec.description   = %q{Enables Vagrant to utilize mutagen for project sync}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/dasginganinja/vagrant-mutagen'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.2.10'
  spec.add_development_dependency 'rake'
end
