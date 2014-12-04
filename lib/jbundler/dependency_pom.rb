bdir = java.lang.System.getProperty( "jbundler.basedir" )
jfile = java.lang.System.getProperty( "jbundler.jarfile" )
gfile = java.lang.System.getProperty( "jbundler.gemfile" )
jworkdir = java.lang.System.getProperty( "jbundler.workdir" )

basedir( bdir )
if basedir != bdir
  # older maven-tools needs this
  self.instance_variable_set( :@basedir, bdir )
end

( 0..(java.lang.System.getProperty( "jbundler.jars.size" ).to_i - 1) ).each do |i|
  dependency_artifact Maven::Tools::Artifact.from_coordinate( java.lang.System.getProperty( "jbundler.jars.#{i}" ).to_s )
end

jarfile( jfile )

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
