jfile = ::Maven::Tools::Jarfile.new( java.lang.System.getProperty( "jbundler.jarfile" ) )
workdir = java.lang.System.getProperty( "jbundler.workdir" )
jworkdir = File.join( workdir, 'jruby_complete' )
FileUtils.mkdir_p( jworkdir )

build.directory = jworkdir

properties( 'maven.test.skip' => true,
            'project.build.sourceEncoding' => 'utf-8' )

jfile.populate_unlocked do |dsl|
  setup_jruby( dsl.jruby || JRUBY_VERSION, :compile )
  dsl.artifacts.select do |a|
    a[ :scope ] == :provided
  end.each do |a|
    a[ :scope ] = :compile
    artifact( a )
  end
end

plugin( :shade, '2.1',
        :outputFile => "${user.dir}/jruby-complete-custom.jar",
        :transformers => [ { '@implementation' => 'org.apache.maven.plugins.shade.resource.ManifestResourceTransformer',
                             :mainClass => 'org.jruby.Main' } ] ) do
  execute_goals( 'shade', :phase => 'package' )
end

plugin( :dependency, '2.8',
        :includeTypes => 'jar',
        :outputAbsoluteArtifactFilename => true,
        :outputFile => java.lang.System.getProperty( "jbundler.outputFile" ) )
