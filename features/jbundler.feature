Feature: Setup classloader with JBundler

  Scenario: checkout a new project with Gemfile.lock and setup the classloader with declared jar dependencies
    Given a fresh copy of "src/example"
    And execute "bundle install" in "my_project"
    And execute "bundle exec info.rb" in "my_project"
    Then the output should contain the list "org/slf4j/slf4j-simple/1.6.4/slf4j-simple-1.6.4.jar,org/slf4j/slf4j-api/1.6.4/slf4j-api-1.6.4.jar,msv/isorelax/20050913/isorelax-20050913.jar,thaiopensource/jing/20030619/jing-20030619.jar,nekohtml/nekodtd/0.1.11/nekodtd-0.1.11.jar,xml-apis/xml-apis/1.0.b2/xml-apis-1.0.b2.jar,net/sourceforge/nekohtml/nekohtml/1.9.15/nekohtml-1.9.15.jar,xerces/xercesImpl/2.9.0/xercesImpl-2.9.0.jar"
