#-*- mode: ruby -*-

require 'maven/ruby/maven'

task :default => [ :test ]

desc 'run integration tests'
task :test do
  warn "currently broken due to missing permissions on bin/mvn"
  Maven::Ruby::Maven.new.verify( '-Dmaven.test.skip' )
end

task :headers do
  require 'copyright_header'

  s = Gem::Specification.load( Dir["*gemspec"].first )

  args = {
    :license => s.license, 
    :copyright_software => s.name,
    :copyright_software_description => s.description,
    :copyright_holders => s.authors,
    :copyright_years => [Time.now.year],
    :add_path => "lib:src",
    :output_dir => './'
  }

  command_line = CopyrightHeader::CommandLine.new( args )
  command_line.execute
end

# vim: syntax=Ruby
