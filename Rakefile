#-*- mode: ruby -*-

require 'maven/ruby/tasks'

task :default => [ :test ]

desc 'run all tests'
task :all do
  maven.verify
end

desc 'run some integration test'
task :integration do
  maven.verify( '-Dmaven.test.skip' )
end

desc 'run all the specs und junit tests'
if ENV[ 'rvm_version' ]
  task :test => [ :minispec ]

  warn 'rvm is not working properly with ruby-maven so NO junit tests'
else
  task :test => [ :minispec, :junit ]
end

task :minispec do
  unless File.exists? File.join('lib', 'jbundler.jar' )
    Rake::Task[ :jar ].invoke
  end
  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.basename(f.sub(/.rb$/, '')) }
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
