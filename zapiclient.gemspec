
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zapiclient/version'

Gem::Specification.new do |spec|
  spec.name          = 'zapiclient'
  spec.version       = Zapiclient::VERSION
  spec.authors       = ['h20dragon']
  spec.email         = ['h20dragon@outlook.com']

  spec.summary       = %q{Zephyr ZAPI for Cloud Client.}
  spec.description   = %q{Simple yet powerful ZAPI for Cloud client for Ruby 2.3.1+.}
  spec.homepage      = 'https://github.com/h20dragon'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.3'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'atlassian-jwt', '~> 0.1.1'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rest-client', '~> 2.0.2'
  spec.add_development_dependency 'rspec', '~> 3.7'
end
