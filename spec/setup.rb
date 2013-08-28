#require 'fileutils'

#FileUtils.mkdir_p 'target'

$LOAD_PATH.unshift './lib' unless $LOAD_PATH.member? './lib'
begin
  require 'minitest'
rescue LoadError
end
require 'minitest/autorun'
