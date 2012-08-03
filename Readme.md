# jbundler [![Build Status](https://secure.travis-ci.org/mkristian/jbundler.png)](http://travis-ci.org/mkristian/jbundler) #

manage jar dependencies similar than **bundler** manages gem dependencies.

* the DSL mimics the one from bundler
* you can use maven like version declaration or rubygems/bundler like version ranges
* it locks down the jar versions inside "Jarfile.lock"
* you can declare jar dependency within a rubygems using the requirements directive of the gem specification. jbundler will include those jar dependencies into its classpath
* on the first run everything get resolved, any further run just the setup of classpath is done (without any maven involved)
* it integrates nicely with bundler when Bundler.require is used (like Rails does it)

## get started

just add it as **first** entry in your *Gemfile* (pending since no gem is released)

```gem 'jbundler'```

such bundler config will trigger the classpath resolution on the first call of ```Bundler.require```, any successive runs will reuse the classpath from *.jbundler/classpath.rb* without any more action with maven.

if you use only **rubygems** or **isolate** then requiring **jbundler** will trigger the classpath setup

```require 'jbundler'```

## Jar dependencies ##

the jar dependencies can either declared in the **Jarfile** or inside the gemspec through the requirements (see also the example directory of this project):

    Gem::Specification.new do |s|
      s.name = 'gem_with_jar'
      s.version = '0.0.0'
      s.requirements << "jar 'org.slf4j:slf4j-api', '1.5.10'"
    end
    
more info about the **[Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile)** or the how to declare [versions](https://github.com/torquebox/maven-tools/wiki/Versions).

## example ##

**please first build the jar file for the jbundler gem, see [Build](https://github.com/mkristian/jbundler/wiki/Build).** 

*src/example/my_project* has a Gemfile which uses a gem which depends on jar dependency. see *src/example/gem_with_jar/gem_with_jar.gemspec* how the jar gets declared.

execute *src/example/my_project/info.rb* to see it in action:

      cd src/example/my_project
      jruby -S jbundle install
      jruby -S bundle exec info.rb

## limitations ##

update of single artifacts is not possible.

since the version resolution happens in two steps - first the gems then the jars/poms - it is possible in case of failure of the second one there could be another set of versions for the gems which would then succeed the jars/poms resolution. but there is plenty of possible ways to improve this (maven could resolve the gems as well, etc)

**Jarfile** is **not** a DSL, i.e. it is not ruby though it could use a ruby DSL to read the data (any contribution welcome).

jbundler does not obey the **$HOME/.m2/settings.xml** from maven where you usually declare proxies, mirrors, etc.

## adding a maven repository ##

see	[Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile)
	
## update ##

update of a single artifact is not possible (yet). but to update the whole set of artifacts just delete the lockfile *Jarfile.lock*

if jbundler sees that **Gemfile.lock** or **Jarfile** is newer then the **.jbundler/classpath.rb** file then jbundler tries to gracefully upgrade towards the changes. the is a maven-like behaviour and once there are command line tools for jbundler they can behave like bundler.

## meta-fu ##

bug-reports and pull request are most welcome.
