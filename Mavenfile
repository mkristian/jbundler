#-*- mode: ruby -*-

aether_version = '1.11' # '1.13'
maven_version = '3.0.3' #'3.0.4'
wagon_version = '1.0-beta-7' #'2.2'

jar 'org.sonatype.aether:aether-api', aether_version
jar 'org.sonatype.aether:aether-util', aether_version
jar 'org.sonatype.aether:aether-impl', aether_version
jar 'org.sonatype.aether:aether-connector-file', aether_version
jar 'org.sonatype.aether:aether-connector-asynchttpclient', aether_version
jar 'org.sonatype.aether:aether-connector-wagon', aether_version
jar 'org.apache.maven:maven-aether-provider', maven_version
jar 'org.apache.maven.wagon:wagon-file', wagon_version
#jar 'org.apache.maven.wagon:wagon-http', wagon_version
jar 'org.apache.maven.wagon:wagon-http-lightweight', wagon_version

# overwrite via cli -Djruby.versions=1.6.7
properties['jruby.versions'] = ['1.5.6','1.6.5.1','1.6.7'].join(',')
# overwrite via cli -Djruby.use18and19=false
properties['jruby.use18and19'] = true

plugin(:minitest) do |m|
  m.execute_goal(:spec)
end

plugin(:cucumber) do |m|
  m.execute_goal(:test)
end

# hack until test profile deps are normal deps with scope 'test'
profile(:test).activation.by_default

# vim: syntax=Ruby
