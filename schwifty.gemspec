# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schwifty/info'

Gem::Specification.new do |spec|
  spec.name          = 'schwifty'
  spec.version       = Schwifty::VERSION
  spec.authors       = ['James Chang']
  spec.email         = ['longboardcat13@sgmail.com']

  spec.summary       = Schwifty::SUMMARY
  spec.description   = Schwifty::DESCRIPTION
  spec.homepage      = 'https://github.com/longboardcat/schwifty'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['schwifty']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'docopt',         '~>0.5.0'
  spec.add_runtime_dependency 'sys-filesystem', '~>1.1.6'
  spec.add_runtime_dependency 'build_execution'

  spec.required_ruby_version = '>= 2.0.0'
end
