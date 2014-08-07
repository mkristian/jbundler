require 'jbundler/configurator'
module JBundler
  class Configurator

    attr_accessor :groups, :bootstrap, :verbose, :compile, :work_dir

    def initialize( config )
      @config = config
    end

    def configure( maven )
      maven.property( 'jbundler.basedir', @config.basedir )
      maven.property( 'jbundler.jarfile', @config.jarfile )
      maven.property( 'jbundler.gemfile', @config.gemfile )
      maven.property( 'jbundler.workdir', work_dir )
      maven.property( 'jbundler.groups', @groups )
      maven.property( 'jbundler.bootstrap', @bootstrap )
      maven.property( 'maven.repo.local', @config.local_repository )
    end

    def work_dir
      @work_dir ||= File.expand_path( @config.work_dir )
    end
  end
end
