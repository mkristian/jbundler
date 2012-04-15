require 'jbundler/classpath_file'
require 'jbundler/mavenfile'
require 'jbundler/gemfile_lock'
require 'jbundler/aether'

describe JBundler::Mavenfile do

  let(:workdir) { 'target' }
  let(:mfile) { File.join(workdir, 'tmp-mvnfile') }
  let(:mfile_lock) { mfile + ".lock"}
  let(:aether) { JBundler::AetherRuby.new }
  subject { JBundler::Mavenfile.new(mfile) }

  before do
    Dir[File.join(workdir, "tmp*")].each { |f| FileUtils.rm_f f }
  end

  it 'generates lockfile' do
    subject.generate_lockfile(%w( a b c d e f))
    File.read(mfile_lock).must_equal <<-EOF
a
b
c
d
e
f
EOF
  end

  it 'check locked coordinate' do
    File.open(mfile_lock, 'w') do |f|
      f.write <<-EOF
a:b:pom:3
a:c:jar:1
EOF
    end
    subject.locked.must_equal ["a:b:pom:3", "a:c:jar:1"]
    subject.locked?("a:b:pom:321").must_equal true
    subject.locked?("a:b:jar:321").must_equal true
    subject.locked?("a:d:jar:432").must_equal false
  end

  it 'populate repositories' do
    File.open(mfile, 'w') do |f|
      f.write <<-EOF
repository :first, "http://example.com/repo"
source 'second', "http://example.org/repo"
EOF
    end
    subject.populate_unlocked aether
    aether.repositories.size.must_equal 3
    aether.artifacts.size.must_equal 0
    aether.repositories[0].id.must_equal "central"
    aether.repositories[1].id.must_equal "first"
    aether.repositories[2].id.must_equal "second"
  end

  it 'populate artifacts without locked' do
    File.open(mfile, 'w') do |f|
      f.write <<-EOF
jar 'a:b', '123'
pom 'x:y', '987'
EOF
    end
    subject.populate_unlocked aether
    aether.repositories.size.must_equal 1 # central
    aether.artifacts.size.must_equal 2
    aether.artifacts[0].to_s.must_equal "a:b:jar:123"
    aether.artifacts[1].to_s.must_equal "x:y:pom:987"
  end

  it 'populate artifacts with locked' do
    File.open(mfile, 'w') do |f|
      f.write <<-EOF
jar 'a:b', '123'
pom 'x:y', '987'
EOF
    end
    File.open(mfile_lock, 'w') do |f|
      f.write <<-EOF
a:b:jar:432
EOF
    end
    
    subject.populate_unlocked aether
    aether.repositories.size.must_equal 1 # central
    aether.artifacts.size.must_equal 1
    aether.artifacts[0].to_s.must_equal "x:y:pom:987"
  end

  it 'populate locked artifacts' do
    File.open(mfile_lock, 'w') do |f|
      f.write <<-EOF
a:b:jar:432
EOF
    end
    
    subject.populate_locked aether
    aether.repositories.size.must_equal 1 # central
    aether.artifacts.size.must_equal 1
    aether.artifacts[0].to_s.must_equal "a:b:jar:432"
  end
end
