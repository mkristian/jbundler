# jbundler [![Build Status](https://secure.travis-ci.org/mkristian/jbundler.png)](http://travis-ci.org/mkristian/jbundler) #

* the DSL mimics the one from bundler
* you can use maven like version declaration or rubygems/bundler like version ranges
* it locks down the versions like bundler inside "Jarfile.lock"
* you can declare jar dependency within a rubygems using the requirements directive of the gem specification. jbundler will include those jar dependencies into its classpath
* on the first run everything get resolved, any further run just the setup of classpath is done (without any maven involved)
* it integrates nicely with bundler when Bundler.require is used

## get started

just add it as **first** entry in your *Gemfile* (pending since no gem is released)

```gem 'jbundler'```

such bundler config will trigger the classpath resolution on the first call of ```Bundler.require```, any successive runs will reuse the classpath from *.jbundler/classpath.rb* without any more action with maven.

if you use only **rubygems** or **isolate** then following require will trigger the classpath setup

```require 'jbundler'```

## example ##

**please first build the jar file for the jbundler gem, see [Build.md](Build.md).** 

*example/my_project* has a Gemfile which uses a gem which depends on jar dependency. see *example/gem_with_jar/gem_with_jar.gemspec* how the jar gets declared.

execute *example/my_project/info.rb* to see it in action:

      cd example/my_project
      jruby -S bundle install
      jruby -S bundle exec info.rb

## limitations ##

update of single artifacts is not possible.

since the version resolution happens in two steps - first the gems then the jars/poms - it is possible in case of failure of the second one there could be another set of versions for the gems which would then succeed the jars/poms resolution. but there is plenty of possible ways to improve this (maven could resolve the gems as well, etc)

**Jarfile** is **not** a DSL, i.e. it is not ruby though it could use a ruby DSL to read the data (any contribution welcome).

jbundler does not obey the **$HOME/.m2/settings.xml** from maven where you usually declare proxies, mirrors, etc.

## adding a maven repository ##

the maven central is default repostory and is always there. adding another repository use following decalration

    repository :first, "http://example.com/repo"
    source 'second', "http://example.org/repo"
    source "http://example.org/repo/3"
	
	
## jar/pom dependencies ##

a pom dependency is not associated with a jar file but has dependencies to other poms or jars. 

dependencies can be declared either in **Jarfile**

    jar 'org.slf4j:slf4j-simple', '> 1.6.2', '< 1.7.0'
    jar 'org.sonatype.aether:aether-api', '1.13'

or inside the gemspec through the requirements (see also the example directory of this project):

    Gem::Specification.new do |s|
      s.name = 'gem_with_jar'
      s.version = '0.0.0'
      s.requirements << "jar 'org.slf4j:slf4j-api', '1.5.10'"
    end
    
### maven like version ###

```jar 'my.group.id:my-artifact-id', '1.2.3'```

this will add the jar dependency for the maven artifact **my.group.id:my-artifact-id** with version **1.2.3**. this version will be treated as **maven version**, i.e. in case of a version conflict the one which is closer to project root will be used (see also: TODO link)

### rubygem like version ###

some example (see also: TODO link)

    jar 'my.group.id:my-artifact-id', '1.2.3'
    pom 'my.group:my-artifact-id', '=1.2.3'
    jar 'my.group.id:artifact-id', '>1.2.3'
    jar 'my.group:artifact-id', '>1.2.3', '=<2.0.1'

the no version will default to **[0,)** (maven version range) which is **>=0** in the rubygems world.

    jar 'group:artifact-id'

the *not* version **!3.4.5** can not be mapped properly to a maven version ranges. **>3.4.5** is used instead in these (rare) cases.

## update ##

update of a single artifact is not possible (yet). but to update the whole set of artifacts just delete the lockfile *Jarfile.lock*

if jbundler sees that **Gemfile.lock** or **Jarfile** is newer then the **.jbundler/classpath.rb** file then jbundler tries to gracefully upgrade towards the changes. the is a maven-like behaviour and once there are command line tools for jbundler they can behave like bundler.

## meta-fu ##

bug-reports and pull request are most welcome.
