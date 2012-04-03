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

the current implementation is proof of concept. for example the embedding of maven is kind of crude and the local maven repository needs to be under $HOME/.m2/repository, etc

## jar/pom dependencies ##

these dependencies can be used either in **Mvnfile** or inside the gemspec through the requirements (see also the example directory of this project):

    Gem::Specification.new do |s|
      s.name = 'gem_with_jar'
      s.version = '0.0.0'
      s.requirements << "jar 'org.slf4j:slf4j-api', '1.5.10'"
    end
    
### with maven like version ###

```jar 'my.group.id:my-artifact-id', '1.2.3'```

this will add the jar dependency for the maven artifact **my.group.id:my-artifact-id** with version **1.2.3**. this version will be treated as **maven version**, i.e. in case of a version conflict the one which is closer to project root will be used (see also: TODO link)

### with rubygem like version ###

some example (see also: TODO link)

```jar 'my.group.id:my-artifact-id', '1.2.3'```
```pom 'my.group:my-artifact-id', '=1.2.3'```
```jar 'my.group.id:artifact-id', '>1.2.3'```
```jar 'my.group:artifact-id', '>1.2.3', '=<2.0.1'```
