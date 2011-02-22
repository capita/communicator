# Rake tasks for the communicator gem.
namespace :communicator do
  desc "Copies all communicator gem migrations to your rails app"
  task :update_migrations do
    fail "Only available in Rails context!" unless defined?(Rails)
    require 'fileutils'
    Dir[File.join(File.dirname(__FILE__), '..', '..', 'db/migrate/*.rb')].each do |migration|
      target = File.join(Rails.root, 'db/migrate', File.basename(migration))
      if File.exist?(target)
        puts "Skipped #{File.basename(migration)}, already present!"
      else
        FileUtils.cp(migration, target)
        puts "Copied #{File.basename(migration)} to your Rails apps' db/migrate folder. Please do rake db:migrate"
      end
    end
  end
  
  desc "Runs Communicator::Client.push and Communicator::Client.pull in current Rails.env"
  task :communicate => :environment do
    begin
      Communicator::Client.push
    rescue => err
      Communicator::ExceptionHandler.publish_and_reraise err, "Status" => "Sync failed while trying to PUSH messages"
    end
    
    begin
      Communicator::Client.pull
    rescue => err
      Communicator::ExceptionHandler.publish_and_reraise err, "Status" => "Sync failed while trying to PULL messages"
    end
    
    # If everything's fine, make sure exception notifications are unlocked and get 
    # delivered again on next occurence
    Communicator::ExceptionHandler.unlock!
  end
  
  desc "Purges inbound and outbound messages - USE WITH CAUTION!!"
  task :purge => :environment do
    Communicator::InboundMessage.delete_all
    Communicator::OutboundMessage.delete_all
  end
end
