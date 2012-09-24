# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'rubyjams'
  s.version = "0.1.0"
  
  s.summary = 'jar dependency support for rubygems'

  s.authors = ['mkristian']

  #s.files = ["MIT-LICENSE", "Rakefile"]
  s.files += Dir['lib/**/*.rb']
  #s.files += Dir['test/**/*.rb']

  s.require_paths = ["lib"]

#  s.add_dependency('jbundler', '~> 0.3')
end

