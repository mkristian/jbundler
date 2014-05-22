#-*- mode: ruby -*-

gemfile

jarfile

jruby_plugin :minitest do
  # restrict the specs since we have more *_spec,rb files deeper the 
  # directory tree
  execute_goals( :spec, :minispecDirectory => 'spec/*_spec.rb' )
end

properties( 'jruby.versions' => ['1.6.8','1.7.4', '1.7.12'].join(','),
            'jruby.modes' => ['1.8', '1.9', '2.0'].join(','),
            # just lock the versions
            'jruby.version' => '1.7.12',
            'tesla.dump.pom' => 'pom.xml',
            'tesla.dump.readonly' => true )

plugin :compiler, '3.1' do
  execute_goals( :testCompile, :phase => 'test-compile' )
end

plugin :surefire, '2.15' do
  execute_goals :test, :phase => :test
end

# TODO use ruby-maven invoker to avoid prebuild pom.xml
#require'ruby-maven'
plugin :invoker, '1.8' do
  execute_goals( :run,
                 :id => 'integration-test',
                 :projectsDirectory => 'integration',
                 :streamLogs => true,
                 #:mavenExecutable => File.join( Gem.loaded_specs['ruby-maven'].bin_dir, 'rmvn' ),
                 :pomIncludes => [ '*' ],
                 :preBuildHookScript => 'setup',
                 :postBuildHookScript => 'verify' )
end

# vim: syntax=Ruby
