# single spec setup
$LOAD_PATH.unshift File.join( File.dirname( File.expand_path( File.dirname( __FILE__ ) ) ),
                              'lib' )

# TODO somehow needed here for executable_spec
require 'maven/tools/coordinate'

begin
  require 'minitest'
rescue LoadError
end
require 'minitest/autorun'

# supress warnings
require 'stringio'
$stderr = StringIO.new
