
Pod::Spec.new do |s|

  s.name         = "Weak Dictionary"
  s.version      = "1.0.1"
  s.summary      = "naive (strong key/weak value) dictionary & (weak key/weak value) dictionary implementations in swift"
  s.homepage     = "https://github.com/nicholascross/WeakDictionary"
  s.license      = 'MIT'
  s.author       = { "Nicholas Cross" => "isthisreallyneeded78908657634257756@gmail.com" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/nacrossweb/SpriteKitElements.git", :tag => "1.0.1" }
  s.source_files  = 'WeakDictionary/*'
  s.requires_arc = true

end