#-*- mode: ruby -*-

raise "\n\n\tuse JRuby for this project !!!!\n\n\n" unless defined? JRUBY_VERSION

require 'maven/ruby/tasks'

task :default => [ :test ]

desc 'run all the specs'
task :test => [ :minispec ]#, :junit ]

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
