# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "another_brick/version"

Gem::Specification.new do |s|
  s.name        = "another_brick"
  s.version     = AnotherBrick::VERSION
  s.authors     = ["Victor Cavalcanti", "Vinicius Higa", "Ricardo Ruiz"]
  s.email       = ["victorc.rodrigues@gmail.com", "viniciushiga@gmail.com", "rhruiz@gmail.com"]
  s.homepage    = "https://github.com/viniciushiga/another_brick"
  s.summary     = "Deploy debian packages using bricklayer"
  s.description = "Creates a testing tag, waits for bricklayer to build the debian package and then updates your server"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"

  s.add_runtime_dependency "slop",          "~> 3.4"
  s.add_runtime_dependency "json",          "~> 1.5"
  s.add_runtime_dependency "rest-client",   "~> 1.6"
  s.add_runtime_dependency "net-ssh",       "~> 2.6.1"
end
