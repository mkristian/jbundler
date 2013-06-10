#-*- mode: ruby -*-

plugin(:minitest) do |m|
  m.execute_goal(:spec)
end

plugin( :jar, '2.4' ).in_phase( 'prepare-package' ).execute_goal( :jar ).with :finalName => "${project.artifactId}", :outputDirectory => "${project.basedir}/lib"

plugin(:clean, '2.5' ).with :filesets => [ { :directory => './',
                                             :includes => [ 'Gemfile.lock', 
                                                            'lib/${project.artifactId}.jar' ] } ]

plugin( :compiler, '3.0' ).with( :target => '1.6', :source => '1.6' )

plugin( :gem ).in_phase( :validate ).execute_goal( :pom ).with( :tmpPom => '.pom.xml', :skipGeneration => true )

# canbe overwritten via cli -Djruby.versions=1.6.7
# putting 1.5.6 at the end works around the problem of installing gems
# with "bad" timestamps
properties['jruby.versions'] = ['1.6.8','1.7.4','1.5.6'].join(',')
# overwrite via cli -Djruby.use18and19=false
properties['jruby.18and19'] = true

# just lock the versions
properties['jruby.plugins.version'] = '1.0.0-beta'
properties['jruby.version'] = '1.7.3'

# TODO get them working again ;)
plugin( :cucumber ).with( :skip => true )
profile 'run-its' do |r|
  r.plugin( :cucumber, '${jruby.plugins.version}' ) do |m|
    m.execute_goal(:test)
    m.with( :skip => false )
  end
end

test_jar 'org.mockito:mockito-core', '1.9.5'
test_jar 'org.testng:testng', '6.8'

# vim: syntax=Ruby
