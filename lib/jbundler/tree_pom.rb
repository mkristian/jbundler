jfile = java.lang.System.getProperty( "jbundler.jarfile" )
gfile = java.lang.System.getProperty( "jbundler.gemfile" )
jworkdir = java.lang.System.getProperty( "jbundler.workdir" )

basedir( File.dirname( jfile ) )

gemfile( gfile ) if File.exists? gfile

jarfile( jfile, :skip_locked => true )

build do
  directory = jworkdir
  default_goal 'dependency:tree'
end
        
properties( 'project.build.sourceEncoding' => 'utf-8',
            'tesla.dump.readOnly' => true,
            'tesla.dump.pom' => 'tree.pom.xml',
            'outputFile' => '${project.build.directory}/tree.txt' )
