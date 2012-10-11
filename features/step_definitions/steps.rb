require 'fileutils'
require 'maven/ruby/cli'
module JBundler
  class Steps

    def initialize(dir)
      @dir = dir
    end

    def rmvn
      @rmvn ||= begin
                  rmvn = Maven::Ruby::Cli.new
                  # copy the jruby version and the ruby version (1.8 or 1.9)
                  # to be used by maven process
                  rmvn.options['-Djruby.version'] = JRUBY_VERSION if defined? JRUBY_VERSION
                  
                  rversion = RUBY_VERSION  =~ /^1.8./ ? '--1.8': '--1.9'
                  rmvn.options['-Djruby.switches'] = rversion
                  rmvn
                end
    end
  
    def logfile
      @logfile
    end

    def execute_java(args, dir)
      @index ||= 0
      @index += 1
      path = File.join(@dir, dir)
      @logfile = File.join(path, "output-#{@index}.log")

      Dir.chdir(path) do
        system("java #{args} > #{File.basename(@logfile)}")
      end
    end

    def execute(args, dir)
      @index ||= 0
      @index += 1
      path = File.join(@dir, dir)
      @logfile = File.join(path, "output-#{@index}.log")
      rmvn.options['-l'] = @logfile
      # maven offline
      #rmvn.options['-o'] = nil
      # lots of maven log
      #rmvn.options['-X'] = nil
      # error stacktrace
      #rmvn.options['-e'] = nil
      # jruby related maven log
      #rmvn.options['-Djruby.verbose'] = true
      # ruby-maven debug
      #rmvn.options['-Dverbose'] = true
      rmvn.options['-Dgem.home'] = ENV['GEM_HOME']
      rmvn.options['-Dgem.path'] = ENV['GEM_PATH']
      unless rmvn.exec_in(path, args.sub(/rmvn\s+/, '').split(' '))
        puts File.read(@logfile)
        raise "failure executing #{args}"
      end
    end
  end
end

steps = nil

Given /^a fresh copy of "(.*)"$/ do |path|
  basedir = File.join('target', File.basename(path))
  steps = JBundler::Steps.new(basedir)
#  FileUtils.rm_rf(basedir)
  FileUtils.cp_r(path, 'target')
end

And /^execute "(.*)" in "(.*)"$/ do |args, dir|
  steps.execute(args, dir)
end

And /^execute java with "(.*)" in "(.*)"$/ do |args, dir|
  steps.execute_java(args, dir)
end

Then /^the output should contain "(.*)"$/ do |text|
  log = File.read(steps.logfile)
  raise "not found '#{text}'" unless log =~ /#{text}/
end

Then /^the output should contain the list "(.*)"$/ do |list|
  log = File.read(steps.logfile)
  list.split(/,/).each do |item|
    unless log =~ /#{item}/
      puts log
      raise "not found '#{item}'" 
    end
  end
end
