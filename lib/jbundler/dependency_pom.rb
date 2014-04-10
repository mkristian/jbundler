bdir = java.lang.System.getProperty( "jbundler.basedir" )
jfile = java.lang.System.getProperty( "jbundler.jarfile" )
gfile = java.lang.System.getProperty( "jbundler.gemfile" )
jworkdir = java.lang.System.getProperty( "jbundler.workdir" )

basedir( bdir )
if basedir != bdir
  # older maven-tools needs this
  self.instance_variable_set( :@basedir, bdir )
end

gemfile( gfile ) if File.exists? gfile

jarfile( jfile, :skip_locked => true )

build do
  directory = jworkdir
end
        
properties( 'project.build.sourceEncoding' => 'utf-8',
            'tesla.dump.readOnly' => true,
            'tesla.dump.pom' => 'tree.pom.xml' )

plugin( :dependency, '2.8',
        :includeTypes => 'jar',
        :outputAbsoluteArtifactFilename => true,
        :outputFile => java.lang.System.getProperty( "jbundler.outputFile" ) )
