# -*- encoding: utf-8 -*-
require File.expand_path('../lib/captivation/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'captivation'
  gem.description   = 'Captivation helps you route reactive streams between your objects'
  gem.homepage      = "https://github.com/kibiz0r/#{gem.name}"
  gem.version       = Captivation::VERSION

  gem.authors       = ['Michael Harrington']
  gem.email         = ['kibiz0r@gmail.com']

  gem.files         = `git ls-files`.split($\)
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'bubble-wrap'
  gem.add_runtime_dependency 'motion_support'
  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'konjure'
  gem.add_runtime_dependency 'coalesce'
  gem.add_runtime_dependency 'reactr'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rr'

  gem.summary       = <<-END.gsub(/^ +/, '')
    I should write something good here.
  END
end
