#-*- mode: ruby -*-

gemfile

jruby_plugin :minitest do
  # restrict the specs since we have more *_spec.rb files deeper in the 
  # directory tree
  execute_goals( :spec, :minispecDirectory => 'spec/*_spec.rb' )
end

properties( 'jruby.versions' => ['1.6.8','1.7.12', '1.7.19', '9.0.0.0.pre1'].join(','),
            'jruby.modes' => ['1.9', '2.0', '2.1'].join(','),
            # just lock the versions
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
