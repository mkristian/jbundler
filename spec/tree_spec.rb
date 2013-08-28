load File.expand_path(File.join( File.dirname( __FILE__ ), 'setup.rb'))
require 'jbundler/tree'
require 'jbundler/config'
require 'stringio'

describe JBundler::Tree do

  it 'should show dependency tree' do
    dir = File.join( File.dirname( __FILE__ ), 'tree' )
    java.lang.System.set_property( 'user.dir', dir )
    FileUtils.cd( dir ) do
      exec = JBundler::Tree.new( JBundler::Config.new )
      output = StringIO.new
      $stdout = output
      exec.show_it( true )
      $stdout = STDOUT
      lines = output.string.split( /\n/ )
      lines = lines.select do |line|
        line =~ /:.+:.+:.+:/
      end
      lines.join( "\n" ).must_equal File.read( 'ref.txt' ).strip
    end

  end

end
