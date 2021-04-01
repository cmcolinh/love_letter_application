lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "love_letter_application/version"

Gem::Specification.new do |spec|
  spec.name          = 'love_letter_application'
  spec.version       = LoveLetterApplication::VERSION
  spec.authors       = ['Colin Horner']
  spec.email         = ['25807014+cmcolinh@users.noreply.github.com']

  spec.summary       = 'Love Letter application'
  spec.description   = 'Runs the application'
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'change_orders'
  spec.add_development_dependency 'dry-auto_inject'
  spec.add_development_dependency 'dry-initializer'
  spec.add_development_dependency 'dry-monads'
  spec.add_development_dependency 'dry-struct'
  spec.add_development_dependency 'dry-types'
  spec.add_development_dependency 'dry-validation'
  spec.add_development_dependency 'game_validator', '~> 0.6.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

