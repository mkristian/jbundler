load File.expand_path(File.join('spec', 'setup.rb'))
require 'jbundler/pom'

describe JBundler::Pom do

  it 'should create jar pom without deps' do
    pom = JBundler::Pom.new("first", "1", [])
    File.read(pom.file).must_equal "<?xml version=\"1.0\" ?><project><modelVersion>4.0.0</modelVersion><groupId>ruby.bundler</groupId><artifactId>first</artifactId><version>1</version><dependencies></dependencies></project>"
    pom.coordinate.must_equal "ruby.bundler:first:jar:1"
  end

  it 'should create pom-pom without deps' do
    pom = JBundler::Pom.new("first", "1", [], 'pom')
    File.read(pom.file).must_equal "<?xml version=\"1.0\" ?><project><modelVersion>4.0.0</modelVersion><groupId>ruby.bundler</groupId><artifactId>first</artifactId><version>1</version><packaging>pom</packaging><dependencies></dependencies></project>"
    pom.coordinate.must_equal "ruby.bundler:first:pom:1"
  end

  it 'should create jar pom without deps' do
    pom = JBundler::Pom.new("second", "1", ["jar \"org.jruby:jruby-core\", '~>1.7.0'"])
    File.read(pom.file).must_equal "<?xml version=\"1.0\" ?><project><modelVersion>4.0.0</modelVersion><groupId>ruby.bundler</groupId><artifactId>second</artifactId><version>1</version><dependencies><dependency><groupId>org.jruby</groupId><artifactId>jruby-core</artifactId><version>[1.7.0,1.7.99999]</version></dependency></dependencies></project>"
    pom.coordinate.must_equal "ruby.bundler:second:jar:1"
  end

  it 'should respect classifiers' do
    pom = JBundler::Pom.new("third", "1", ["jar \"org.jruby:jruby-core\", '~>1.7.0'", "pom \"f:g:jdk15\", \">1.2\", \"<=2.0\""])
    File.read(pom.file).must_equal "<?xml version=\"1.0\" ?><project><modelVersion>4.0.0</modelVersion><groupId>ruby.bundler</groupId><artifactId>third</artifactId><version>1</version><dependencies><dependency><groupId>org.jruby</groupId><artifactId>jruby-core</artifactId><version>[1.7.0,1.7.99999]</version></dependency><dependency><groupId>f</groupId><artifactId>g</artifactId><version>(1.2,2.0]</version><type>pom</type><classifier>jdk15</classifier></dependency></dependencies></project>"
    pom.coordinate.must_equal "ruby.bundler:third:jar:1"
  end

end
