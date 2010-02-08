# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{syncro}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex MacCaw"]
  s.date = %q{2010-02-08}
  s.description = %q{Sync Ruby classes between clients.}
  s.email = %q{info@eribium.org}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "README",
     "Rakefile",
     "VERSION",
     "examples/.gitignore",
     "examples/test_client.rb",
     "examples/test_server.rb",
     "lib/syncro.rb",
     "lib/syncro/app.rb",
     "lib/syncro/client.rb",
     "lib/syncro/marshal.rb",
     "lib/syncro/model.rb",
     "lib/syncro/protocol/message.rb",
     "lib/syncro/protocol/message_buffer.rb",
     "lib/syncro/redis.rb",
     "lib/syncro/redis/client.rb",
     "lib/syncro/redis/scriber/scribe.rb",
     "lib/syncro/response.rb",
     "lib/syncro/scriber.rb",
     "lib/syncro/scriber/model.rb",
     "lib/syncro/scriber/observer.rb",
     "lib/syncro/scriber/scribe.rb",
     "syncro.gemspec"
  ]
  s.homepage = %q{http://github.com/maccman/syncro}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Sync Ruby classes between clients.}
  s.test_files = [
    "examples/test_client.rb",
     "examples/test_server.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_runtime_dependency(%q<supermodel>, [">= 0.0.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_dependency(%q<supermodel>, [">= 0.0.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
    s.add_dependency(%q<supermodel>, [">= 0.0.1"])
  end
end

