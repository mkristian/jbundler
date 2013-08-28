#-*- mode: ruby -*-

gemspec

jarfile

plugin( 'de.saumya.mojo:minitest-maven-plugin', '${jruby.plugins.version}' ) do
  execute_goals(:spec)
end

plugin( :compiler, '3.1', :target => '1.6', :source => '1.6' )

# can be overwritten via cli -Djruby.versions=1.6.7
# putting 1.5.6 at the end works around the problem of installing gems
# with "bad" timestamps
properties( 'jruby.versions' => ['1.6.8','1.7.4','1.5.6'].join(','),
            # overwrite via cli -Djruby.use18and19=false
            'jruby.18and19' => true,
            # just lock the versions
            'jruby.plugins.version' => '1.0.0-beta-1-SNAPSHOT',
            'jruby.version' => '1.7.4',
            'tesla.dump.pom' => 'pom.xml',
            'tesla.dump.readonly' => true )

scope :test do
  jar 'org.mockito:mockito-core', '1.9.5'
  jar 'org.testng:testng', '6.8'
end

# vim: syntax=Ruby
