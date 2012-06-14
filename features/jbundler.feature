Feature: Setup classloader with JBundler

  Scenario: checkout a new project with Gemfile.lock and setup the classloader with declared jar dependencies
    Given a fresh copy of "src/example"
    And execute "bundle install" in "my_project"
    And execute "gem exec info.rb" in "my_project"
    Then the output should contain the list "org/slf4j/slf4j-simple/1.6.4/slf4j-simple-1.6.4.jar,org/slf4j/slf4j-api/1.6.4/slf4j-api-1.6.4.jar,msv/isorelax/20050913/isorelax-20050913.jar,thaiopensource/jing/20030619/jing-20030619.jar,nekohtml/nekodtd/0.1.11/nekodtd-0.1.11.jar,xml-apis/xml-apis/1.0.b2/xml-apis-1.0.b2.jar,net/sourceforge/nekohtml/nekohtml/1.9.15/nekohtml-1.9.15.jar,xerces/xercesImpl/2.9.0/xercesImpl-2.9.0.jar"

  # Scenario: checkout a new gem project without Gemfile.lock and setup the classloader with declared jar dependencies
  #   Given a fresh copy of "src/example"
  #   And execute "bundle install" in "gem_project"
  #   And execute "rmvn gem exec info.rb" in "gem_project"
  #   Then the output should contain the list "org/bouncycastle/bcmail-jdk15on/1.47/bcmail-jdk15on-1.47.jar,org/bouncycastle/bcprov-jdk15on/1.47/bcprov-jdk15on-1.47.jar,org/bouncycastle/bcpkix-jdk15on/1.47/bcpkix-jdk15on-1.47.jar"

  # Scenario: checkout a new gem project and create an executable jar
  #   Given a fresh copy of "src/example"
  #   And execute "rmvn package -P executable" in "gem_with_jar"
  #   And execute java with "-jar gem_with_jar-0.0.0-jar-with-dependencies-and-gems.jar run" in "gem_with_jar/target"
  #   Then the output should contain "may all be happy"
