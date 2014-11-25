#-*- mode: ruby -*-

AETHER_VERSION = '0.9.0.M2'
MAVEN_VERSION = '3.1.0'
WAGON_VERSION = '2.4'

jar 'org.eclipse.aether:aether-api', AETHER_VERSION
jar 'org.eclipse.aether:aether-util', AETHER_VERSION
jar 'org.eclipse.aether:aether-impl', AETHER_VERSION
jar 'org.eclipse.aether:aether-connector-file', AETHER_VERSION
jar 'org.eclipse.aether:aether-connector-asynchttpclient', AETHER_VERSION
jar 'org.eclipse.aether:aether-connector-wagon', AETHER_VERSION
jar 'org.apache.maven:maven-aether-provider', MAVEN_VERSION
jar 'org.apache.maven.wagon:wagon-file', WAGON_VERSION
jar 'org.apache.maven.wagon:wagon-http', WAGON_VERSION
jar 'org.apache.maven:maven-settings', MAVEN_VERSION
jar 'org.apache.maven:maven-settings-builder', MAVEN_VERSION

scope :test do
  jar 'org.mockito:mockito-core', '1.9.5'
  jar 'org.testng:testng', '6.8'
end

jruby '1.7.11', :no_asm => true do
  # resolve version conflict for jruby
  jar 'org.yaml:snakeyaml:1.13'
end


#jar 'org.apache.hbase:hbase-annotations', '=0.98.7-hadoop2'
# vim: syntax=Ruby
