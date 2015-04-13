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
                 :properties => { 'jbundler.version' => '${project.version}' } )
end

profile!( :gemfile_lock ) do
  # bundler will be ignored by bundler via Gemfile.lock
  gem 'bundler', '~> 1.6'
end

# vim: syntax=Ruby
