jfile = java.lang.System.getProperty( "jbundler.jarfile" )
gfile = java.lang.System.getProperty( "jbundler.gemfile" )
jworkdir = java.lang.System.getProperty( "jbundler.workdir" )

basedir( File.dirname( jfile ) )

gemfile( gfile ) if File.exists? gfile

jarfile( jfile )

build do
  directory = jworkdir
  default_goal 'dependency:list'
end
        
plugin( :dependency, '2.8',
        :includeTypes => 'jar',
        :outputAbsoluteArtifactFilename => true,
        :outputFile => "#{jworkdir}/dependencies.txt" )

properties( 'project.build.sourceEncoding' => 'utf-8',
            'tesla.dump.readOnly' => true,
            'tesla.dump.pom' => 'lockdown.pom.xml'  )
