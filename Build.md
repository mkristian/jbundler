# build jbundler #

the build uses ruby-maven. **note** ruby-maven uses maven and maven is highly modular, i.e. it comes only with the core and the moment you need a plugin he first time its starts downloading it. with that in mind the first usage of (ruby-)maven involves a lot of downloading - so be prepared :)

first get all the development gems in place:

```jruby -S bundle install```

to build the (extension) jar for the lib directory (prepare the jar before packaging the gem)

```rmvn prepare-package```

this also runs all the test over a couple of jruy version each in 1.8 and 1.9 mode. so these tests take some time. in skip the tests when building the gem use:

```rmvn prepare-package -DskipTests```

to build the gem in **target/jbundler-0.0.1.gem**

```rmvn package```

or once the jar file is in place then

```gem build jbundler.gemspec```

will do as well.

## proper maven and IDEs ##

once ```rmvn``` generated the **Gemfile.pom** you can use proper maven3 by setting a sybolic link from **pom.xml** to **Gemfile.pom**. in the end rmvn is just ruby wrapper around maven3. the **Gemfile.pom** is generated from the *jbundler.gemspec*, *Gemfile*, *Gemfile.lock* and *Mavenfile*.

your IDE might be able to use the pom.xml to manage the project and its java sources.

