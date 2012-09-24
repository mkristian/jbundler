`gem build rubyjams.gemspec; jruby -S gem install rubyjams-*.gem -l; jruby -S gem install nokogiri-maven; jruby -rubygems -e 'require "rubyjams";gem "nokogiri-maven"; require "nokogiri"'`

