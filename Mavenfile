#-*- mode: ruby -*-

aether_version = '1.13'
maven_version = '3.0.4'
wagon_version = '2.2'

jar 'org.sonatype.aether:aether-api', aether_version
jar 'org.sonatype.aether:aether-util', aether_version
jar 'org.sonatype.aether:aether-impl', aether_version
jar 'org.sonatype.aether:aether-connector-file', aether_version
jar 'org.sonatype.aether:aether-connector-asynchttpclient', aether_version
jar 'org.sonatype.aether:aether-connector-wagon', aether_version
jar 'org.apache.maven:maven-aether-provider', maven_version
jar 'org.apache.maven.wagon:wagon-file', wagon_version
jar 'org.apache.maven.wagon:wagon-http', wagon_version
#jar 'org.apache.maven.wagon:wagon-http-lightweight', wagon_version
jar 'org.apache.maven:maven-settings', maven_version
jar 'org.apache.maven:maven-settings-builder', maven_version

# overwrite via cli -Djruby.versions=1.6.7
properties['jruby.versions'] = ['1.5.6','1.6.8','1.7.2'].join(',')
# overwrite via cli -Djruby.use18and19=false
properties['jruby.18and19'] = true

plugin(:minitest) do |m|
  m.execute_goal(:spec)
end

profile 'run-its' do |r|
  r.plugin( :cucumber, '${jruby.plugins.version}' ) do |m|
    m.execute_goal(:test)
  end
end

execute_in_phase( :initialize ) do
  pom = File.read( 'pom.xml' )
  dot_pom = File.read( '.pom.xml' )
  if pom != dot_pom
    File.open( 'pom.xml', 'w' ) { |f| f.puts dot_pom }
  end
end

# vim: syntax=Ruby
