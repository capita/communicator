require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :db do
  desc "Drop, create and migrate the test databases"
  task :migrate do
    require 'active_record'
    require 'logger'
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
    # For background on what is going on here, please have a look at:
    # http://stackoverflow.com/questions/1993071/how-to-controller-start-kill-a-background-process-server-app-in-ruby
    # http://stackoverflow.com/questions/224512/redirect-the-puts-command-output-to-a-log-file
    
    # Dynamically choose a port to use so tests can run concurrently!
    server_port = 20000+rand(2000)
    
    # Clean up tmp dir and make sure test_server.log file exists
    system("rm tmp/*")
    system("touch tmp/test_server.log")
    
    pid = fork do
      $stdout.reopen("tmp/test_server.log", "w+")
      $stdout.sync = true
      $stderr.reopen($stdout)
      # Write the port into a tempfile so tests can figure out where to run against!
      File.open('tmp/server_port', "w+") do |f|
        f.print server_port
      end
      exec "bundle exec rackup test/config.ru -s webrick -p #{server_port}"
    end

    # Wait for WEBrick to boot...
    retries = 0
    print "Waiting for test server to start on localhost:#{server_port}"
    while retries += 1 and not File.read('tmp/test_server.log') =~ /HTTPServer/
      print '.'
      sleep 1
      fail "Test server did not start in time, exiting..." if retries > 20
    end
  
    Kernel.at_exit do
      system("rm tmp/*")
      Process.kill "KILL", pid
      Process.wait pid
    end
  end

end

# Make sure database and test server are in place when tests start
task :test => :"db:migrate"
task :test => :"test_server:start"
task :default => :test
