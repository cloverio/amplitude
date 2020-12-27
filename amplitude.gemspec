require File.join([File.dirname(__FILE__), 'lib', 'amplitude', 'version.rb'])

Gem::Specification.new do |spec|
  spec.name          = 'amplitude'
  spec.version       = Amplitude::VERSION
  spec.summary       = 'Ruby bindings for the Transmission RPC API.'
  spec.description   = 'Amplitude is a Transmission RPC client written in ruby.'
  spec.authors       = ['Kevin Manson', 'Guillaume Coguiec']
  spec.email         = ['kev.manson@gmail.com', 'mail@gcoguiec.com']
  spec.homepage      = 'https://github.com/cloverio/amplitude'
  spec.platform      = Gem::Platform::RUBY
  spec.licenses      = ['MIT']
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.files         = %w(amplitude.gemspec LICENSE)
  spec.files         += Dir.glob('lib/**/*.rb')
  spec.require_paths << 'lib'

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency('httparty', '~> 0.17.3')

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
