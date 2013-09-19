# jbundler 

* [![Build Status](https://secure.travis-ci.org/mkristian/jbundler.png)](http://travis-ci.org/mkristian/jbundler) #

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

#### Building

building the jar
```rake jar```

building the gem
```rake build```

running the junit test
```rake junit```

running the minitest
```rake minitest```

make sure you use jruby ;)

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

    jbundle console

further it adds two methods to the root level:

    > jars

to list the loaded jars and

    > jar 'org.yaml:snakeyaml'

using the same syntax as use in the **Jarfile**. there are limitations with such a lazy jar loading but it is very convenient when trying out things.

## lazy jar loading ##

    require 'jbundler/lazy'
	include JBundler::Lazy
	
will offer the same `jar`/`jars` method than you have inside the console.

# extra commands

## jbundler tree

shows the dependency tree - without the locked version. i.e. an install or update would result in the shown version.

with locked down versions that tree is more hint then a real picture of the situation !!

## jruby executable -b start.rb

will create an executable jar file using the given ruby script as bootstrap script. it will include the comple jruby and all the dependent jars as well all the gems packed into it as well. the

     jruby '1.7.4'

declaration in the *Jarfile* will determinate the jruby version to use for the executable jar.

## example ##

*src/example/my_project* has a Gemfile which uses a gem which depends on jar dependency. see *src/example/gem_with_jar/gem_with_jar.gemspec* how the jar gets declared.

execute *src/example/my_project/info.rb* to see it in action:

      cd src/example/my_project
      jbundle install
      bundle exec info.rb

## limitations ##

update of single artifacts is not possible.

since the version resolution happens in two steps - first the gems then the jars/poms - it is possible in case of a failure that there is a valid gems/jars version resolution which satisfies all version contraints. so there is plenty of space for improvements (like maven could resolve the gems as well, etc)

**Jarfile** is **not** a DSL but it could use a ruby DSL to read the data (any contribution welcome).

jbundler does not completely obey the **$HOME/.m2/settings.xml** from maven where you usually declare proxies, mirrors, etc. see [jbundler configuration](https://github.com/mkristian/jbundler/wiki/Configuration) for what is already possible.

## RVM and/or rubygems-bundler ##

some tests did not work with RVM and/or rubygems-bundler - there are some weird classloader issue popping up. there is a problem with the way the classloader gets setup. but a manual jruby installion or using rbenv is just working fine.

those issue might pop up with ```jbunle tree`` and ```jbundle executable```

## update ##

update of a single artifact is not possible (yet). but to update the whole set of artifacts just delete the lockfile *Jarfile.lock*

if jbundler sees that **Gemfile.lock** or **Jarfile** is newer then the **.jbundler/classpath.rb** file then jbundler tries to gracefully upgrade towards the changes.

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
