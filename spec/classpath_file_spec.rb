require 'jbundler/classpath_file'
require 'jbundler/mavenfile'
require 'jbundler/gemfile_lock'

describe JBundler::ClasspathFile do

  let(:workdir) { 'target' }
  let(:mfile) { File.join(workdir, 'tmp-mvnfile') }
  let(:gfile_lock) { File.join(workdir, 'tmp-gemfile.lock') }
  let(:mfile_lock) { mfile + ".lock"}
  let(:cpfile) { File.join(workdir, 'tmp-cp.rb') }
  let(:mavenfile) { JBundler::Mavenfile.new(mfile) }
  let(:gemfile_lock) { JBundler::GemfileLock.new(mavenfile, gfile_lock) }
  subject { JBundler::ClasspathFile.new(cpfile) }

  before do
    Dir[File.join(workdir, "tmp*")].each { |f| FileUtils.rm_f f }
    FileUtils.touch gfile_lock #assume there is always a Gemfile.lock
  end

  it 'needs update when all files are missing' do
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'needs update when only mavenfile' do
    FileUtils.touch mfile
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'needs update when mavenfilelock is missing' do
    FileUtils.touch mfile
    FileUtils.touch cpfile
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'needs no update when classpath file is the youngest' do
    FileUtils.touch mfile
    FileUtils.touch mfile_lock
    FileUtils.touch cpfile
    subject.needs_update?(mavenfile,gemfile_lock).must_equal false
  end

  it 'needs update when maven file is the youngest' do
    FileUtils.touch mfile_lock
    FileUtils.touch cpfile
    sleep 1
    FileUtils.touch mfile
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'needs update when maven lockfile is the youngest' do
    FileUtils.touch mfile
    FileUtils.touch cpfile
    sleep 1
    FileUtils.touch mfile_lock
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'needs update when gem lockfile is the youngest' do
    FileUtils.touch mfile
    FileUtils.touch cpfile
    FileUtils.touch mfile_lock
    sleep 1
    FileUtils.touch gfile_lock
    subject.needs_update?(mavenfile,gemfile_lock).must_equal true
  end

  it 'generates a classpath ruby file' do
    subject.generate("a:b:c:d:f:".gsub(/:/, File::PATH_SEPARATOR))
    File.read(cpfile).must_equal <<-EOF
JBUNDLER_CLASSPATH = []
JBUNDLER_CLASSPATH << 'a'
JBUNDLER_CLASSPATH << 'b'
JBUNDLER_CLASSPATH << 'c'
JBUNDLER_CLASSPATH << 'd'
JBUNDLER_CLASSPATH << 'f'
JBUNDLER_CLASSPATH.freeze
JBUNDLER_CLASSPATH.each { |c| require c }
EOF
  end
end
