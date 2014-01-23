load File.expand_path(File.join('spec', 'setup.rb'))
require 'jbundler/config'
require 'fileutils'

describe JBundler::Config do

  before do     
    ENV.keys.each do |k|
      ENV.delete( k ) if k.to_s.match /^(J?)BUNDLE/
    end
    if defined? JRUBY_VERSION     
      java.lang.System.properties.keys.each do |k|
        java.lang.System.properties.delete( k ) if k.to_s.match /^(j?)bundle/
      end          
    end
  end

  it 'has following defaults without home and without local config' do
    ENV['HOME'] = '.'
    
    FileUtils.cd( 'spec' ) do
      c = JBundler::Config.new
      c.verbose.must_equal nil
      c.local_repository.must_equal nil
      c.jarfile.must_equal 'Jarfile'
      c.gemfile.must_equal 'Gemfile'
      c.skip.must_equal nil
      c.settings.must_equal nil 
      c.offline.must_equal false
      c.work_dir.must_equal 'pkg'
      c.vendor_dir.must_equal 'vendor/jars'
    end
  end

  it 'has following defaults without home and with local config' do
    ENV['HOME'] = '.'
    
    FileUtils.cd( File.join( 'spec', 'project' ) ) do
      c = JBundler::Config.new

      c.verbose.must_equal true
      c.local_repository.must_equal 'local'
      c.jarfile.must_equal 'Jar_file'
      c.gemfile.must_equal 'gemfile'
      c.skip.must_equal false
      c.settings.must_equal 'settings.xml'
      c.offline.must_equal true
      c.work_dir.must_equal 'pkg'
      c.vendor_dir.must_equal 'vendor/myjars'
    end
  end

  it 'has following defaults with home and without local config' do
    ENV['HOME'] = File.join( 'home' )

    FileUtils.cd( 'spec' ) do
      c = JBundler::Config.new
          
      c.verbose.must_equal false
      c.local_repository.must_equal 'localrepo'
      c.jarfile.must_equal 'jarfile'
      c.gemfile.must_equal 'Gem_file'
      c.skip.must_equal true
      c.settings.must_equal 'Settings.xml'
      c.offline.must_equal false
      c.work_dir.must_equal 'target/pkg'
      c.vendor_dir.must_equal 'vendor/my_jars'
    end
  end

  it 'has following defaults with home and with local config' do
    ENV['HOME'] = File.expand_path( File.join( 'spec', 'home' ) )

    FileUtils.cd( File.join( 'spec', 'project' ) ) do
      c = JBundler::Config.new
    
      c.verbose.must_equal true
      c.local_repository.must_equal 'local'
      c.jarfile.must_equal 'Jar_file'
      c.gemfile.must_equal 'gemfile'
      c.skip.must_equal false
      c.settings.must_equal 'settings.xml'
      c.offline.must_equal true
      c.work_dir.must_equal 'pkg'
      c.vendor_dir.must_equal 'vendor/myjars'
    end
  end

  describe 'ENV and java.lang.System.properties' do
    before do
      ENV[ 'JBUNDLE_VERBOSE' ] = 'true'
      ENV[ 'JBUNDLE_LOCAL_REPOSITORY' ] = 'local_repository'
      ENV[ 'JBUNDLE_JARFILE' ] = 'JarFile'
      ENV[ 'BUNDLE_GEMFILE' ] = 'GemFile'
      ENV[ 'JBUNDLE_SETTINGS' ] = 'Settings.xml'
      ENV[ 'JBUNDLE_SKIP' ] = 'false'
      ENV[ 'JBUNDLE_OFFLINE' ] = 'true'
      ENV[ 'JBUNDLE_WORK_DIR' ] = 'pkg/work'
      ENV[ 'JBUNDLE_VENDOR_DIR' ] = 'vendor/localjars'
    end

    [ 'spec', 'spec/home' ].each do |home|

      [ 'spec', 'spec/project' ].each do |dir|

        it "uses ENV with home #{home} and local dir #{dir}" do
          ENV['HOME'] = eval "\"#{File.expand_path( home )}\""
          
          FileUtils.cd eval "\"#{dir}\"" do
            c = JBundler::Config.new
            c.verbose.must_equal true
            c.local_repository.must_equal 'local_repository'
            c.jarfile.must_equal 'JarFile'
            c.gemfile.must_equal 'GemFile'
            c.skip.must_equal false
            c.settings.must_equal 'Settings.xml'
            c.offline.must_equal true
            c.work_dir.must_equal 'pkg/work'
            c.vendor_dir.must_equal 'vendor/localjars'
          end
        end
        
        it 'uses java.lang.System.properties with home #{home} and local dir #{dir}' do
          ENV['HOME'] = eval "\"#{File.expand_path( home )}\""

          java.lang.System.set_property 'jbundle.verbose', 'false'
          java.lang.System.set_property 'jbundle.local.repository', 'local_repo'
          java.lang.System.set_property 'jbundle.jarfile', 'Jar_File'
          java.lang.System.set_property 'bundle.gemfile', 'Gem_File'
          java.lang.System.set_property 'jbundle.settings', 'settings.xml'
          java.lang.System.set_property 'jbundle.skip', 'true'
          java.lang.System.set_property 'jbundle.offline', 'false'
          java.lang.System.set_property 'jbundle.work.dir', 'target/work'
          java.lang.System.set_property 'jbundle.vendor.dir', 'vendor/local_jars'
          
          FileUtils.cd eval "\"#{dir}\"" do
            c = JBundler::Config.new
            c.verbose.must_equal false
            c.local_repository.must_equal 'local_repo'
            c.jarfile.must_equal 'Jar_File'
            c.gemfile.must_equal 'Gem_File'
            c.skip.must_equal true
            c.settings.must_equal 'settings.xml'
            c.offline.must_equal false
            c.work_dir.must_equal 'target/work'
            c.vendor_dir.must_equal 'vendor/local_jars'
          end
        end
      end
    end
  end
end

