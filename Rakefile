#-*- mode: ruby -*-

require 'ruby-maven'
require 'fileutils'
require 'maven/ruby/pom_magic'

task :default => [ :test ]

task :common do
  raise "you need jruby to run this" unless defined? JRUBY_VERSION
  @rmvn = Maven::Ruby::Maven.new
  @rmvn.options['-f'] = Maven::Ruby::PomMagic.new.generate_pom#( '.', 'pom.xml' )
end

task :build => [ :common ] do
  @rmvn.options['-Dmaven.test.skip'] = true
  if @rmvn.exec('package')
    puts ''
    puts 'you find the gem inside the "target" directory'
    puts ''
  else
    raise 'failed'
  end
end

task :compile => [ :common ] do
  @rmvn.options['-Dmaven.test.skip'] = true
  # jruby related debug log
  @rmvn.options['-Djruby.verbose'] = true
  # compiles java sources and build the jar

  unless @rmvn.exec('prepare-package')
    raise 'failed'
  end
end

task :features => [ :compile ] do
  rversion = RUBY_VERSION  =~ /^1.8./ ? '--1.8': '--1.9'
  @rmvn.options['-Djruby.versions'] = '1.7.2'#JRUBY_VERSION
  @rmvn.options['-Djruby.switches'] = rversion
  @rmvn.options['-Djruby.18and19'] = false
  # jruby related debug log
  #rmvn.options['-Djruby.verbose'] = true
  # lots of maven debug log
  #rmvn.options['-X'] = nil
  unless @rmvn.exec('cucumber')
    raise 'failed'
  end
end

task :test => [ :common ] do
  puts '-----------------------------------------------------'
  puts
  puts 'to compile the jar and run test use the minitest task'
  puts
  puts '-----------------------------------------------------'
  puts
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.basename(f.sub(/.rb$/, '')) }
end

task :minispec => [ :compile ] do
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.basename(f.sub(/.rb$/, '')) }
end

task :clean do
  @rmvn.exec 'clean'
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
