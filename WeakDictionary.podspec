
Pod::Spec.new do |s|

  s.name         = "WeakDictionary"
  s.version      = "2.0.2"
  s.summary      = "A naive (strong key/weak value) dictionary & (weak key/weak value) dictionary implementations in swift"
  s.homepage     = "https://github.com/nicholascross/WeakDictionary"
  s.license      = 'MIT'
  s.author       = { "Nicholas Cross" => "isthisreallyneeded78908657634257756@gmail.com" }

  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/nicholascross/WeakDictionary.git", :tag => s.version }
  s.source_files  = 'WeakDictionary/*.swift'
  s.requires_arc  = true
  s.swift_version = '4.2'

end