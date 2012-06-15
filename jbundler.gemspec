Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.2.0'

  s.summary = 'bundler support for maven or/and maven support for bundler'
  s.description = <<-END
using embedded maven to add jar support to bundler and add bundler like handling of version ranges to maven
END

  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']
  s.homepage = 'https://github.com/mkristian/jbundler'

  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.files += Dir['Gemfile*']
  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_runtime_dependency "ruby-maven", "= 3.0.4.0.29.0"
  s.add_development_dependency "rake", "0.9.2.2"

end
