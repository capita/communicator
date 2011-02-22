module Communicator::ExceptionHandler
  class << self
    def publish_and_reraise(err, subsections)
      # Notify using capita/exception_notification fork, but only
      # when notifications are not locked
      if respond_to?(:report_exception) and not locked?
        report_exception err, subsections
        lock!
      end
      
      # Always re-raise!
      raise err
    end
    
    # Returns the path to the lockfile, either in rails/tmp if present,
    # otherwise in system-wide tmp
    def lockfile
      if defined?(Rails)
        Rails.root.join('tmp', 'communicator_exception.lock')
      else
        '/tmp/communicator_exception.lock'
      end
    end
    
    # Checks whether mailing exceptions is currently locked
    def locked?
      File.exist?(lockfile)
    end
    
    # Creates the exception notifier lockfile
    def lock!
      File.open(lockfile, "w+") do |f|
        f.puts "Locked at #{Time.now}"
      end
    end
    
    # Removes the exception notifier lockfile
    def unlock!
      File.unlink(lockfile) if locked?
    end
  end  
end
