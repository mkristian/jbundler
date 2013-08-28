load File.expand_path(File.join( File.dirname( __FILE__ ), 'setup.rb'))
require 'jbundler/executable'
require 'jbundler/config'
require 'fileutils'

describe JBundler::Executable do

  before do
    dir = File.join( File.dirname( __FILE__ ), 'executable' )
    java.lang.System.set_property( 'user.dir', dir )
    FileUtils.rm_rf( File.join( dir, 'target' ) )
    Dir.chdir( dir )
  end

  it 'should create executable jar' do
    exec = JBundler::Executable.new( 'start.rb', 
                                     JBundler::Config.new )
    exec.groups = [:default]
    exec.packit
    
    `java -jar target/executable/executable.jar`.must_equal 'hello world'
  end

end
