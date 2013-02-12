# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lwrf/lwrf-version"

Gem::Specification.new do |s|
  s.name        = "siriproxy-lwrf"
  s.version     = Lwrf::VERSION 
  s.authors     = ["ian"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{A SiriProxy Plugin For LightWaveRF}
  s.description = %q{This is a SiriProxy Plugin For LightWaveRF. It simply intercepts the phrases to control LightWaveRF devices and responds with a message about the command that is sent to the LightWaveRF gem. }

  s.rubyforge_project = "siriproxy-lwrf"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "lightwaverf"
end
