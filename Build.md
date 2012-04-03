# build jbundler #

the build uses ruby-maven

```jruby -S gem install ruby-maven'```

to build the jar for the lib directory (prepare the jar before packaging the gem)

```rmvn prepare-package```

to build the gem. the create gem will be **target/jbundler-0.0.1.gem**

```rmvn package```

## pom.xml for the IDE ##

the pom.xml is generated from the *jbundler.gemspec* and *Mavenfile*. it will be written out to *jbundler.gemspec.pom*. in case the IDE needs a pom.xml just set a symlic link.
