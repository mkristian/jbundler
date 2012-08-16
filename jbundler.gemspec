Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.3.0'

  s.summary = 'managing jar dependencies'
  s.description = <<-END
managing jar dependencies with or without bundler. adding bundler like handling of version ranges for jar dependencies.
END

  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']
  s.homepage = 'https://github.com/mkristian/jbundler'

  s.bindir = "bin"
  s.executables = ['jbundle']

  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.files += Dir['Gemfile*']
  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_runtime_dependency "ruby-maven", "= 3.0.4.0.29.0"
  s.add_development_dependency "rake", "0.9.2.2"
  s.add_development_dependency "thor", "< 0.16.0", "> 0.14.0"

end
