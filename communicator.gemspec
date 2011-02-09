# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "communicator/version"

Gem::Specification.new do |s|
  s.name        = "communicator"
  s.version     = Communicator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christoph Olszowka"]
  s.email       = ["christoph at olszowka de"]
  s.homepage    = "http://github.com/capita/communicator"
  s.summary     = %Q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}
  s.description = %Q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}

  s.rubyforge_project = "communicator"
  
  s.add_dependency 'sinatra', "~> 1.1.0"
  s.add_dependency 'activerecord', "< 3.0.0"
  s.add_dependency 'httparty', '>= 0.6.1'
  s.add_dependency 'json', '>= 1.4.0'
  s.add_development_dependency "shoulda", "2.10.3"
  s.add_development_dependency 'factory_girl', ">= 1.2.3"
  s.add_development_dependency 'rack-test', ">= 0.5.6"
  s.add_development_dependency 'bundler', ">= 1.0.0"
  s.add_development_dependency 'sqlite3-ruby', ">= 1.3.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
