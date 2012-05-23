Gem::Specification.new do |s|
  s.name = 'gem_with_jar'
  s.version = '0.0.0'
  s.requirements << "jar 'org.slf4j:slf4j-api', '1.5.10'" 
  s.summary = 'summary'
  s.author = 'author'
  s.files = Dir['lib/**']
end

