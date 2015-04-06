#-*- mode: ruby -*-

gemfile

properties( # just lock the versions
            'jruby.version' => '1.7.19',
            'jruby.plugins.version' => '1.0.9',
            'tesla.dump.pom' => 'pom.xml',
            'tesla.dump.readonly' => true )

# TODO use ruby-maven invoker to avoid prebuild pom.xml
#require'ruby-maven'
plugin :invoker, '1.8' do
  execute_goals( :install, :run,
                 :id => 'integration-test',
                 :projectsDirectory => 'integration',
                 :streamLogs => true,
                 :cloneProjectsTo => '${project.build.directory}',
                 :properties => { 'jbundler.version' => '${project.version}' } )
end

# vim: syntax=Ruby
