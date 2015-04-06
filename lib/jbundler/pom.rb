bdir = java.lang.System.getProperty( "jbundler.basedir" )
jfile = java.lang.System.getProperty( "jbundler.jarfile" )

basedir( bdir )
if basedir != bdir
  # older maven-tools needs this
  self.instance_variable_set( :@basedir, bdir )
end

( 0..10000 ).each do |i|
  coord = java.lang.System.getProperty( "jbundler.jars.#{i}" )
  break unless coord
  artifact = Maven::Tools::Artifact.from_coordinate( coord.to_s )
  # HACK around broken maven-tools
  if artifact.exclusions
    ex = artifact.classifier[1..-1] + ':' +  artifact.exclusions.join(':')
    artifact.classifier = nil
    artifact.exclusions = ex.split /,/
  end
  dependency_artifact( artifact ) 
end

jarfile( jfile )

properties( 'project.build.sourceEncoding' => 'utf-8' )

plugin_repository :id => 'sonatype-snapshots', :url => 'https://oss.sonatype.org/content/repositories/snapshots'
jruby_plugin :gem, '1.0.10-SNAPSHOT'

plugin :dependency, '2.8'

# some output
model.dependencies.each do |d|
  puts "      " + d.group_id + ':' + d.artifact_id + (d.classifier ? ":" + d.classifier : "" ) + ":" + d.version + ':' + (d.scope || 'compile')
end
