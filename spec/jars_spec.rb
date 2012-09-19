require 'rubygems'
require 'spec_helper'
require 'lib/jars'
  
describe "Jars", "#require" do 
  
  it "should start with an empty classpath" do
    # this should be nil!!
    $CLASSPATH.size.should == 0
    require 'solr_sail'
  end
  
  it "should set jars" do
    jars.is_a?( Jars ).should be_true
  end
  
  it "should set gems_size" do
    Kernel.class_eval( '@@gems_size' ).size.should eql 8
  end
  
  it "should have loaded jars" do
    jars.loaded.should eql( {} )
  end
  
  it "should set classpath" do
    # XXX: need to assert correct jars are in the classpath
    $CLASSPATH.size.should eql( 58 )
  end
  
  it "should have correctly loaded SolrSail" do
    defined?(SolrSail).should be_true
    SolrSail.class.should eql(Module)
    
    # start and stop solr to prove classpath is valid
    SolrSail.install_config( :solr_home => 'tmp/solr' )
    # manually load the jar packaged with the gem
    $CLASSPATH << SolrSail::DEFAULT_JAR
    
    # Start and stop solr
    @server = com.tobedevoured.solrsail.JettyServer.new( 'tmp/solr' )
    @server.start
    @server.stop
  end
end
