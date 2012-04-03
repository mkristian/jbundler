# jbundler #

just add it as **first** entry in your *Gemfile* (pending since no gem is released)

```gem 'jbundler'```

such bundler config will trigger the classpath resolution on the first call of ```Bundler.require```, any successive runs will reuse the classpath from *.jbundler/classpath.rb* without any more action with maven.

if you use only **rubygems** or **isolate** then following require will trigger the classpath setup

```require 'jbundler'```

## example ##

*example/my_project* has a Gemfile which uses a gem which itself depends on jar dependency - see *example/gem_with_jar/gem_with_jar.gemspec* how the jar got declared.

execute *example/my_project/info.rb* to see it in action:

      cd example/my_project
      jruby -S bundle install
      jruby -S bundle exec info.rb

## limitations ##

the current implmentation is proof of concept. for example the embedding of maven is kind of crude and the local maven repository needs to be under $HOME/.m2/repository, etc
