#-*- mode: ruby -*-

Gem::Specification.new do |s|
  s.name = 'first'
  s.version = '1.1.1'
  s.author = 'example person'
  s.email = [ 'mail@example.com' ]
  s.summary = 'first gem with jars vendored during installation'

  s.files << Dir[ 'lib/**/*.rb' ]
  s.files << Dir[ '*file' ]
  s.files << 'first.gemspec'

  s.platform = 'java'
  s.add_runtime_dependency 'jar-dependencies', '~> 0.1'

  s.requirements << "jar 'org.apache.hbase:hbase-annotations', '=0.98.7-hadoop2'"
  s.requirements << 'jar org.jruby:jruby, 1.7.20, :scope => :provided'
end

# vim: syntax=Ruby
