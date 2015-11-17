# jbundler 

* [![Build Status](https://secure.travis-ci.org/mkristian/jbundler.png)](http://travis-ci.org/mkristian/jbundler) #

manage jar dependencies similar to how **bundler** manages gem dependencies:

* the DSL mimics the one from bundler
* you can use maven-like version declarations or rubygems/bundler version ranges
* it locks down the jar versions inside "Jarfile.lock"
* you can declare jar dependencies within a gem using the requirements directive of the gem specification. jbundler will include those jar dependencies into its classpath

differences compared to **bundler**

* it is just a development gem - no need for it during runtime. just add ```Jars.require_jars_lock!``` to your code and for older JRuby versions add ```gem 'jar-dependencies', '~> 0.1.11'``` as a runtime dependency.
* you need to run ```bundle install``` first if any of the gems have jar dependencies.
* all one command ```jbundle```, see ```jbundle --help``` on the possible options and how to update a single jar, etc.

## get started

install JBundler with

    jruby -S gem install jbundler
	
first create a **Jarfile**, something like:
    
	jar 'org.yaml:snakeyaml', '1.14'
	jar 'org.slf4j:slf4j-simple', '>1.1'

### Jarfile

more info about the **[Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile)** and about [versions](https://github.com/torquebox/maven-tools/wiki/Versions).

for adding a maven repository see [Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile).

# Building the jbundler gem

running the integration test

    ./mvnw verify

building the gem (see ./pkg)

    ./mvnw package -Dinvoker.skip

or just

    gem build jbundler.gemspec

## example ##

*src/example/my_project* has a Gemfile which uses a gem which depends on jar dependency. see *src/example/gem_with_jar/gem_with_jar.gemspec* how the jar gets declared.

execute *src/example/my_project/info.rb* to see it in action:

      cd src/example/my_project
      jbundle install
      bundle exec info.rb

## limitations ##

since the version resolution happens in two steps - first the gems then the jars/poms - it is possible in case of a failure that there is a valid gems/jars version resolution which satisfies all version contraints. so there is plenty of space for improvements (like maven could resolve the gems as well, etc)

# special thanks #

the whole project actually started with a controversial discussion on a [pull request on bundler](https://github.com/carlhuda/bundler/pull/1683). this very same pull request were the starting point of that project here. probably by now there is no much left of the original code but many thanks to [ANithian](https://github.com/ANithian) for given the seed of that project.

License
-------

Almost all code is under the MIT license but the java class (AetherSettings.java)[https://github.com/mkristian/jbundler/blob/master/src/main/java/jbundler/AetherSettings.java] which was derived from EPL licensed code.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

meta-fu
-------

enjoy :) 
