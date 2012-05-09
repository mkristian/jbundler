require 'fileutils'
require 'ruby-maven'
module JBundler
  class Steps

    def initialize(dir)
      @dir = dir
    end

    def rmvn
      @rmvn ||= begin
                  rmvn = Maven::RubyMaven.new
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
    
    def execute(args, dir)
      @index ||= 0
      @index += 1
      path = File.join(@dir, dir)
      @logfile = File.join(path, "output-#{@index}.log")
      rmvn.options['-l'] = File.basename(@logfile)
      rmvn.options['-o'] = nil
      #rmvn.options['-X'] = nil
      #rmvn.options['-Djruby.verbose'] = true
      rmvn.options['-Dgem.home'] = ENV['GEM_HOME']
      rmvn.options['-Dgem.path'] = ENV['GEM_PATH']
      if args =~ /bundle install/
        # maven does manage Gemfile and install all gems
        # bundler will create the Gemfile.lock as needed
        rmvn.exec_in(path,  args.split(' '))
      else
        # run without pom, i.e. maven does not manage Gemfile
        rmvn.options['--no-pom'] = true
        script = File.join(ENV['GEM_HOME'], 'bin', args.sub(/\s+.*$/, ''))
        rmvn.exec_in(path, ['jruby', script] + args.sub(/^[^\s]+\s+/, '').split(' '))
      end
    end
  end
end

steps = nil

Given /^a fresh copy of "(.*)"$/ do |path|
  basedir = File.join('target', File.basename(path))
  steps = JBundler::Steps.new(basedir)
  FileUtils.rm_rf(basedir)
  FileUtils.cp_r(path, 'target')
end

And /^execute "(.*)" in "(.*)"$/ do |args, dir|
  steps.execute(args, dir)
end

Then /^the output should contain the list "(.*)"$/ do |list|
  log = File.read(steps.logfile)
  list.split(/,/).each do |item|
    raise "not found '#{item}'" unless log =~ /#{item}/
  end
end
