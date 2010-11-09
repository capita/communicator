# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{communicator}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph Olszowka"]
  s.date = %q{2010-11-09}
  s.description = %q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}
  s.email = %q{christoph at olszowka de}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     ".rvmrc",
     "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "communicator.gemspec",
     "db/migrate/20101101075419_create_inbound_messages.rb",
     "db/migrate/20101101075719_create_outbound_messages.rb",
     "lib/communicator.rb",
     "lib/communicator/active_record_integration.rb",
     "lib/communicator/client.rb",
     "lib/communicator/inbound_message.rb",
     "lib/communicator/outbound_message.rb",
     "lib/communicator/server.rb",
     "lib/communicator/tasks.rb",
     "test/config.ru",
     "test/factories.rb",
     "test/helper.rb",
     "test/lib/comment.rb",
     "test/lib/post.rb",
     "test/lib/test_server_database/comment.rb",
     "test/lib/test_server_database/inbound_message.rb",
     "test/lib/test_server_database/outbound_message.rb",
     "test/lib/test_server_database/post.rb",
     "test/migrate/20101101093519_create_posts.rb",
     "test/migrate/20101103120519_create_comments.rb",
     "test/test_client.rb",
     "test/test_message_models.rb",
     "test/test_server.rb"
  ]
  s.homepage = %q{http://github.com/colszowka/communicator}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Data push/pull between apps with local inbound/outbound queue and easy publish/process interface}
  s.test_files = [
    "test/factories.rb",
     "test/helper.rb",
     "test/lib/comment.rb",
     "test/lib/post.rb",
     "test/lib/test_server_database/comment.rb",
     "test/lib/test_server_database/inbound_message.rb",
     "test/lib/test_server_database/outbound_message.rb",
     "test/lib/test_server_database/post.rb",
     "test/migrate/20101101093519_create_posts.rb",
     "test/migrate/20101103120519_create_comments.rb",
     "test/test_client.rb",
     "test/test_message_models.rb",
     "test/test_server.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<activerecord>, ["< 3.0.0"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.6.1"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.0"])
      s.add_development_dependency(%q<shoulda>, ["= 2.10.3"])
      s.add_development_dependency(%q<factory_girl>, [">= 1.2.3"])
      s.add_development_dependency(%q<rack-test>, [">= 0.5.6"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.4.0"])
    else
      s.add_dependency(%q<sinatra>, ["~> 1.1.0"])
      s.add_dependency(%q<activerecord>, ["< 3.0.0"])
      s.add_dependency(%q<httparty>, [">= 0.6.1"])
      s.add_dependency(%q<json>, [">= 1.4.0"])
      s.add_dependency(%q<shoulda>, ["= 2.10.3"])
      s.add_dependency(%q<factory_girl>, [">= 1.2.3"])
      s.add_dependency(%q<rack-test>, [">= 0.5.6"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
      s.add_dependency(%q<jeweler>, [">= 1.4.0"])
    end
  else
    s.add_dependency(%q<sinatra>, ["~> 1.1.0"])
    s.add_dependency(%q<activerecord>, ["< 3.0.0"])
    s.add_dependency(%q<httparty>, [">= 0.6.1"])
    s.add_dependency(%q<json>, [">= 1.4.0"])
    s.add_dependency(%q<shoulda>, ["= 2.10.3"])
    s.add_dependency(%q<factory_girl>, [">= 1.2.3"])
    s.add_dependency(%q<rack-test>, [">= 0.5.6"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.0"])
    s.add_dependency(%q<jeweler>, [">= 1.4.0"])
  end
end

