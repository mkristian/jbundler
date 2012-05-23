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

JRUBY_VERSIONS = ['1.5.6','1.6.5.1','1.6.7'].join(',')
plugin(:minitest) do |m|
  m.gem(:minitest, '2.10.0')
  m.gem(:bundler, '1.1.3')
  m.execute_goal(:spec)
  m.with :use18and19 => true, :versions => JRUBY_VERSIONS
end

plugin(:cucumber) do |m|
  m.gem(:cucumber, '1.1.9')
  m.gem(:bundler, '1.1.3')
  m.execute_goal(:test)
  m.with :use18and19 => true, :versions => JRUBY_VERSIONS
end

# hack until test profile deps are normal deps with scope 'test'
profile(:test).activation.by_default

# vim: syntax=Ruby
