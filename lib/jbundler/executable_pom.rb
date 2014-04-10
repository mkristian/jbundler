begin
  groups = java.lang.System.getProperty( "jbundler.groups" ) || ''
  require 'bundler'
  Bundler.setup( *groups.split( /,/ ) )
rescue LoadError
  # ignore- bundler is optional
end

jfile = ::Maven::Tools::Jarfile.new( java.lang.System.getProperty( "jbundler.jarfile" ) )

workdir = java.lang.System.getProperty( "jbundler.workdir" )
jworkdir = File.join( workdir, 'executable' )
FileUtils.rm_rf( jworkdir )
FileUtils.mkdir_p( jworkdir )

BOOTSTRAP = 'jar-bootstrap.rb' unless defined? BOOTSTRAP

FileUtils.cp( java.lang.System.getProperty( 'jbundler.bootstrap'), 
              File.join( jworkdir, BOOTSTRAP ) )

def jruby_home( path )
  File.join( 'META-INF/jruby.home/lib/ruby/gems/shared', path )
end
 
jfile.locked.each do |dep|
  artifact( dep )
end

build.directory = jworkdir
resource do 
  directory jworkdir
  includes [ BOOTSTRAP ]
end
Gem.loaded_specs.values.each do |s|
  resource do 
    directory s.full_gem_path
    target_path File.join( jruby_home( 'gems' ),
                           File.basename( s.full_gem_path ) )
    if s.full_gem_path == File.expand_path( '.' )
      excludes [ "**/#{workdir}/**" ]
    end
  end
  resource do 
    directory File.dirname( s.loaded_from )
    includes [ File.basename( s.loaded_from ) ]
    target_path jruby_home( 'specifications' )
  end            
end

properties( 'maven.test.skip' => true,
            'tesla.dump.pom' => 'pom.xml',
            'project.build.sourceEncoding' => 'utf-8' )

jfile.populate_unlocked do |dsl|
  
  setup_jruby( dsl.jruby || JRUBY_VERSION, :compile )
  dsl.artifacts.select do |a|
    a[ :scope ] == :provided
  end.each do |a|
    a[ :scope ] = :compile
    artifact( a )
  end
  local = dsl.artifacts.select do |a|
    a[ :system_path ]
  end

  # setup a localrepo for the local jars if needed
  if local
    localrepo = File.join( jworkdir, 'localrepo' )
    repository( "file:#{localrepo}", :id => 'localrepo' )
    local.each do |a|
      file = "#{localrepo}/#{a[ :group_id ].gsub( /\./, File::SEPARATOR)}/#{a[ :artifact_id ]}/#{a[ :version ]}/#{a[ :artifact_id ]}-#{a[ :version ]}.#{a[ :type ]}"
      FileUtils.mkdir_p( File.dirname( file ) )
      FileUtils.cp( a.delete( :system_path ), file )
      a.delete( :scope )
      jar a
    end
  end
end

profile :compile do
  
  properties 'jruby.plugins.version' => Maven::Tools::VERSIONS[ :jruby_plugins ]
  plugin( 'de.saumya.mojo:jruby-maven-plugin', '${jruby.plugins.version}' ) do
    execute_goal( :compile,
                  :rubySourceDirectory => 'lib',
                  :jrubycVerbose => @verbose)
  end
end

profile :no_compile do
  build do
  resource do 
    directory '${basedir}/lib'
    includes [ '**/*.rb' ]
  end
  end
end

plugin( :shade, '2.1',
        :outputFile => "${user.dir}/#{File.basename( File.expand_path( '.' ) )}_exec.jar",
        :transformers => [ { '@implementation' => 'org.apache.maven.plugins.shade.resource.ManifestResourceTransformer',
                             :mainClass => 'org.jruby.JarBootstrapMain' } ] ) do
  execute_goals( 'shade', :phase => 'package' )
end
