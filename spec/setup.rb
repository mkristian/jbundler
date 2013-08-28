$LOAD_PATH.unshift File.join( File.dirname( File.expand_path( File.dirname( __FILE__ ) ) ),
                              'lib' )

begin
  require 'minitest'
rescue LoadError
end
require 'minitest/autorun'
