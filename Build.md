# build jbundler #

the build uses ruby-maven

```jruby -S bundle install```

to build the jar for the lib directory (prepare the jar before packaging the gem)

```rmvn prepare-package```

to build the gem in **target/jbundler-0.0.1.gem**

```rmvn package```

or once the jar file is in place then

```gem build jbundler.gemspec```

will do as well.

## proper maven and IDEs ##

once ```rmvn``` generated the **jbundler.gemspec.pom** you can use proper maven3 by setting a sybolic link **pom.xml** to **jbundler.gemspec.pom**. in the end rmvn is just ruby wrapper around maven3. the **jbundler.gemspec.pom** is generated from the *jbundler.gemspec* and *Mavenfile*.

your IDE might be able to use the pom.xml to manage the project and its java sources.

