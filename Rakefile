require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "communicator"
    gem.summary = %Q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}
    gem.description = %Q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}
    gem.email = "christoph at olszowka de"
    gem.homepage = "http://github.com/colszowka/communicator"
    gem.authors = ["Christoph Olszowka"]
    gem.add_dependency 'sinatra', "~> 1.1.0"
    gem.add_dependency 'activerecord', "< 3.0.0"
    gem.add_dependency 'httparty', '>= 0.6.1'
    gem.add_dependency 'json', '>= 1.4.0'
    gem.add_development_dependency "shoulda", "2.10.3"
    gem.add_development_dependency 'factory_girl', ">= 1.2.3"
    gem.add_development_dependency 'rack-test', ">= 0.5.6"
    gem.add_development_dependency 'bundler', ">= 1.0.0"
    gem.add_development_dependency 'sqlite3-ruby', ">= 1.3.0"
    gem.add_development_dependency 'jeweler', '~> 1.4.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end



namespace :db do
  desc "Drop, create and migrate the test databases"
  task :migrate do
    require 'active_record'
    # Drop existing db
    system "rm db/*.sqlite3"
    dev_null = File.new('/dev/null', 'w')
    ActiveRecord::Base.logger = Logger.new(dev_null)
    ActiveRecord::Migration.verbose = false
  
    # Create and migrate test databases for server and client
    %w(test_client test_server).each do |db_name|
      ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "db/#{db_name}.sqlite3")
      ActiveRecord::Migrator.migrate('db/migrate')
      ActiveRecord::Migrator.migrate('test/migrate')
    end
  end
end

namespace :test_server do
  desc "Starts the test server"
  task :start do
    Thread.new do
      # Capture sinatra output (to hide it away...)
      require "open3"
      rackup = "bundle exec rackup test/config.ru -p 20359 --pid=#{File.join(File.dirname(__FILE__), 'test', 'rack.pid')}"
      Open3.popen3(rackup)
      #`#{rackup}` # Uncomment to see actual server output
      
    end
    sleep 2.0
  
    Kernel.at_exit do
      Rake::Task["test_server:stop"].invoke
    end
  end

  desc "Stops the test server"
  task :stop do
    begin
      pid = File.read(File.join(File.dirname(__FILE__), 'test', 'rack.pid')).strip.chomp
      `kill -s KILL #{pid}`
      puts "Killed test server with PID #{pid}"
    rescue => err
      puts "Nothing to stop..."
    end
  end
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies
# Make sure database and test server are in place when tests start
task :test => :"db:migrate"
task :test => :"test_server:start"

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "communicator #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
