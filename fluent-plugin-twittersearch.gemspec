# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-twittersearch"
  s.version     = "0.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Freddie Fujiwara"]
  s.date        = %q{2013-09-29}
  s.email       = "github@ze.gs"
  s.homepage    = "http://github.com/freddiefujiwara/fluent-plugin-twittersearch"
  s.summary     = "twittersearch plugin for Fluentd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency %q<fluentd>, ["~> 0.10.0"]
  s.add_dependency %q<twitter>, ["~> 4.8.1"]
  s.add_dependency %q<rake>,    ["~> 10.1.0"]

  s.license = 'MIT'
end
