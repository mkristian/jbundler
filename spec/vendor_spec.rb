load File.expand_path(File.join('spec', 'setup.rb'))
require 'jbundler/classpath_file'
require 'jbundler/vendor'
require 'maven/tools/jarfile'
require 'jbundler/gemfile_lock'

JBUNDLER_CLASSPATH = []
describe JBundler::Vendor do

  let( :workdir ) { File.join('pkg', 'tmp') }
  let( :vdir ) { File.join(workdir, 'jars') }
  let( :jfile ) { File.join(workdir, 'jarfile') }
  let( :gfile_lock ) { File.join(workdir, 'gemfile.lock') }
  let( :jfile_lock ) { jfile + ".lock"}
  let( :cpfile ) { File.join(workdir, 'cp.rb') }
  let( :jarfile ) { Maven::Tools::Jarfile.new(jfile) }
  let( :gemfile_lock ) { JBundler::GemfileLock.new(jarfile, gfile_lock) }
  let( :cp ) { JBundler::ClasspathFile.new(cpfile) }
  let( :jars ) { [ '1.jar', '2.jar' ] }
  subject { JBundler::Vendor.new( vdir ) }

  before do
    FileUtils.mkdir_p(workdir)
    Dir[File.join(workdir, '*')].each { |f| FileUtils.rm_f f }
    FileUtils.rm_rf(vdir)
    FileUtils.mkdir_p(vdir)
    jars.each do |f|
      FileUtils.touch( File.join( workdir, f ) )
    end
  end

  it 'is not vendored' do
    subject.vendored?.must_equal false
    subject.require_jars.size.must_equal 0
    FileUtils.rm_rf( vdir )
    subject.vendored?.must_equal false
  end

  it 'should copy jars on setup and delete them on clear' do
    ::JBUNDLER_CLASSPATH.replace Dir[ File.join( workdir, "*.jar" )]
    def cp.require_classpath
      [ '1.jar', '2.jar' ]
    end

    subject.setup( cp )

    j = Dir[ File.join( vdir, '*' ) ].collect do |f|
      File.basename( f )
    end
    j.sort.must_equal jars.sort

    subject.vendored?.must_equal true

    subject.require_jars.size.must_equal 2

    subject.clear
    Dir[ File.join( vdir, '*' ) ].must_equal []
  end

end
