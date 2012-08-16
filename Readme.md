# jbundler [![Build Status](https://secure.travis-ci.org/mkristian/jbundler.png)](http://travis-ci.org/mkristian/jbundler) #

manage jar dependencies similar than **bundler** manages gem dependencies.

* the DSL mimics the one from bundler
* you can use maven like version declaration or rubygems/bundler like version ranges
* it locks down the jar versions inside "Jarfile.lock"
* you can declare jar dependency within a rubygems using the requirements directive of the gem specification. jbundler will include those jar dependencies into its classpath
* on the first run everything get resolved, any further run just the setup of classpath is done (without any maven involved)
* it integrates nicely with bundler when Bundler.require is used (like Rails does it)

## get started

install JBundler with

    jruby -S gem install jbundler
	
first create a **Jarfile**, something like
    
	jar 'org.yaml:snakeyaml'
	jar 'org.slf4j:slf4j-simple', '>1.1'

### together with Bundler

just add it as **first** entry in your *Gemfile* 

```gem 'jbundler'```

and now install the bundle both **gems and jars**

    jbundle install

#### Gemfile only

if there is only a **Gemfile** and no Jarfile **jbundler** just handles all the declared [jar dependencies of gems](https://github.com/mkristian/jbundler/wiki/Build). it will only look into gems which bundler loaded.

#### Gemfile and Jarfile

if there is only a **Gemfile** and no Jarfile **jbundler** handles all the declared [jar dependencies of gems](https://github.com/mkristian/jbundler/wiki/Build) as well all the jars from the Jarfile. it will only look into gems which bundler loaded.

### without Bundler - Jarfile only

requiring **jbundler** will trigger the classpath setup

```require 'jbundler'```

this you can use with **rubygems** or **isolate** or . . .

### Jarfile

more info about the **[Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile)** and about [versions](https://github.com/torquebox/maven-tools/wiki/Versions).

for adding a maven repository see [Jarfile](https://github.com/torquebox/maven-tools/wiki/Jarfile).
    
## console ##

like bundler there is a console which sets up the gems (if there is Gemfile otherwise that part get skipped) and sets up the classloader:

    jbundler console

further it adds two methods to the root level:

    > jars

to list the loaded jars and

    > jar 'org.yaml:snakeyaml'

using the same syntax as use in the **Jarfile**. there are limitations with such a lazy jar loading but it is very convenient when trying out things.

## lazy jar loading ##

    require 'jbundler/lazy'
	include JBundler::Lazy
	
will offer the same `jar`/`jars` method than you have inside the console.

## example ##

**please first build the jar file for the jbundler gem, see [Build](https://github.com/mkristian/jbundler/wiki/Build).** 

*src/example/my_project* has a Gemfile which uses a gem which depends on jar dependency. see *src/example/gem_with_jar/gem_with_jar.gemspec* how the jar gets declared.

execute *src/example/my_project/info.rb* to see it in action:

      cd src/example/my_project
      jbundle install
      bundle exec info.rb

## limitations ##

update of single artifacts is not possible.

since the version resolution happens in two steps - first the gems then the jars/poms - it is possible in case of a failure that there is a valid gems/jars version resolution which satisfies all version contraints. so there is plenty of space for improvements (like maven could resolve the gems as well, etc)

**Jarfile** is **not** a DSL but it could use a ruby DSL to read the data (any contribution welcome).

jbundler does not yet obey the **$HOME/.m2/settings.xml** from maven where you usually declare proxies, mirrors, etc.
	
## update ##

update of a single artifact is not possible (yet). but to update the whole set of artifacts just delete the lockfile *Jarfile.lock*

if jbundler sees that **Gemfile.lock** or **Jarfile** is newer then the **.jbundler/classpath.rb** file then jbundler tries to gracefully upgrade towards the changes.

## meta-fu ##

bug-reports and pull request are most welcome.
