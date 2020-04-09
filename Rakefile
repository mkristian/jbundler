task :default => [ :specs ]

unless Rake::Application.method_defined? :last_comment
  Rake::Application.module_eval do
    alias_method :last_comment, :last_description
  end
end # Rake 11 compatibility (due rspec/core/rake_task < 3.0)

desc 'run specs'
task :specs do
  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each do |f| 
    require File.basename( f.sub(/.rb$/, '' ) )
  end
end

desc 'run integration test'
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
