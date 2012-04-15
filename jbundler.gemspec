Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.0.1'
  s.summary = 'bundler support for maven or/and maven support for bundler'
  s.description = <<-END
using embedded maven to add jar support to bundler and add bundler like handling of version ranges to maven
END
  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']
  s.files = Dir['lib/**/*rb'] + ['lib/jbundler.jar', 'MIT-LICENSE'] + Dir['*.md']
  s.add_runtime_dependency "ruby-maven", "= 3.0.3.0.28.7.pre"
end
