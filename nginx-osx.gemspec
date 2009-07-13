# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nginx-osx}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabe Varela"]
  s.date = %q{2009-07-13}
  s.default_executable = %q{nginx-osx}
  s.email = %q{gvarela@gmail.com}
  s.executables = ["nginx-osx"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/nginx-osx",
     "features/nginx-osx.feature",
     "features/step_definitions/nginx-osx_steps.rb",
     "features/support/env.rb",
     "lib/nginx-osx.rb",
     "nginx-osx.gemspec",
     "templates/nginx.conf.erb",
     "templates/nginx.vhost.conf.erb",
     "test/nginx-osx_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/gvarela/nginx-osx}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{gem for using nginx in development}
  s.test_files = [
    "test/nginx-osx_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
