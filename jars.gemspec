# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'jars'
  s.version = "0.1.0"
  
  s.summary = 'jar dependency support for rubygems'

  s.authors = ['mkristian']

  #s.files = ["MIT-LICENSE", "Rakefile"]
  s.files += Dir['lib/**/*.rb']
  #s.files += Dir['test/**/*.rb']

  s.require_paths = ["lib"]

  s.add_development_dependency('rake', '0.9.2.2')
end

