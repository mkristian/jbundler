#TODO get 'spec' into $LOAD by minispec-maven-plugin
load File.expand_path(File.join('spec', 'setup.rb'))
require 'maven/tools/jarfile'
require 'jbundler/aether'

describe JBundler::AetherRuby do

  let(:workdir) { 'target' }
  let(:jfile) { File.join(workdir, 'tmp-jarfile') }
  let(:jfile_lock) { jfile + ".lock"}
  let(:jarfile) { Maven::Tools::Jarfile.new(jfile) }
  subject { JBundler::AetherRuby.new }

  before do
    Dir[File.join(workdir, "tmp*")].each { |f| FileUtils.rm_f f }
  end

  it 'repositories' do
    File.open(jfile, 'w') do |f|
      f.write <<-EOF
repository :first, "http://example.com/repo"
source 'second', "http://example.org/repo"
EOF
    end
    jarfile.populate_unlocked subject
    subject.repositories.size.must_equal 3
    subject.artifacts.size.must_equal 0
    subject.repositories[0].id.must_equal "central"
    subject.repositories[1].id.must_equal "first"
    subject.repositories[2].id.must_equal "second"
  end

  it 'artifacts without locked' do
    File.open(jfile, 'w') do |f|
      f.write <<-EOF
jar 'a:b', '123'
pom 'x:y', '987'
EOF
    end
    jarfile.populate_unlocked subject
    subject.repositories.size.must_equal 1 # central
    subject.artifacts.size.must_equal 2
    subject.artifacts[0].to_s.must_equal "a:b:jar:123"
    subject.artifacts[1].to_s.must_equal "x:y:pom:987"
  end

  it 'artifacts with locked' do
    File.open(jfile, 'w') do |f|
      f.write <<-EOF
jar 'a:b', '123'
pom 'x:y', '987'
EOF
    end
    File.open(jfile_lock, 'w') do |f|
      f.write <<-EOF
a:b:jar:432
EOF
    end
    
    jarfile.populate_unlocked subject
    subject.repositories.size.must_equal 1 # central
    subject.artifacts.size.must_equal 1
    subject.artifacts[0].to_s.must_equal "x:y:pom:987"
  end

  it 'locked artifacts' do
    File.open(jfile_lock, 'w') do |f|
      f.write <<-EOF
a:b:jar:432
EOF
    end
    
    jarfile.populate_locked subject
    subject.repositories.size.must_equal 1 # central
    subject.artifacts.size.must_equal 1
    subject.artifacts[0].to_s.must_equal "a:b:jar:432"
  end
end
