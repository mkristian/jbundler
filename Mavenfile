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

plugin(:jar, '2.3.1').in_phase('prepare-package').execute_goal(:jar).with :outputDirectory => '${project.basedir}/lib', :finalName => '${project.artifactId}'

# vim: syntax=Ruby
