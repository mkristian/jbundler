#-*- mode: ruby -*-

gemfile

properties( 'maven.test.skip' => true,
            # just lock the versions
            'jruby.version' => '1.7.22',
            'jruby.plugins.version' => '1.0.10' )

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

profile!( :gemfile_lock ) do
  # bundler will be ignored by bundler via Gemfile.lock
  gem 'bundler', '~> 1.6'
end

# vim: syntax=Ruby
