Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.4.2'

  s.summary = 'managing jar dependencies'
  s.description = <<-END
managing jar dependencies with or without bundler. adding bundler like handling of version ranges for jar dependencies.
END

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']
  s.homepage = 'https://github.com/mkristian/jbundler'

  s.bindir = "bin"
  s.executables = ['jbundle']

  s.license = 'MIT'

  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.files += Dir['Gemfile*']
  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_runtime_dependency "ruby-maven", "~> 3.0.4"
  s.add_runtime_dependency "maven-tools", "~> 0.32.1"
  s.add_development_dependency "rake", "~> 10.0.3"
  s.add_development_dependency "thor", "< 0.16.0", "> 0.14.0"
  s.add_development_dependency "cucumber", "~> 1.1.9"
  s.add_development_dependency "minitest", "~> 4.3"
  s.add_development_dependency "copyright-header", "1.0.8"
end
