#-*- mode: ruby -*-

gemfile

properties( # just lock the versions
            'jruby.version' => '1.7.19',
            'jruby.plugins.version' => '1.0.9' )

# TODO use ruby-maven invoker to avoid prebuild pom.xml
#require'ruby-maven'
plugin :invoker, '1.8' do
  execute_goals( :install, :run,
                 :id => 'integration-test',
                 :projectsDirectory => 'integration',
                 :streamLogs => true,
                 :cloneProjectsTo => '${project.build.directory}',
                 :properties => { 'jbundler.version' => '${project.version}',
                   'jruby.version' => '${jruby.version}',
                   'jruby.plugins.version' => '${jruby.plugins.version}',
                   'bundler.version' => '1.9.3', 
                   # dump pom for the time being - for travis
                   'polyglot.dump.pom' => 'pom.xml' } )
end

# vim: syntax=Ruby
