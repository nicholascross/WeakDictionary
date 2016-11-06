
Pod::Spec.new do |s|

  s.name         = "WeakDictionary"
  s.version      = "1.2.2"
  s.summary      = "naive (strong key/weak value) dictionary & (weak key/weak value) dictionary implementations in swift"
  s.homepage     = "https://github.com/nicholascross/WeakDictionary"
  s.license      = 'MIT'
  s.author       = { "Nicholas Cross" => "isthisreallyneeded78908657634257756@gmail.com" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/nicholascross/WeakDictionary.git", :tag => "1.2.2" }
  s.source_files  = 'WeakDictionary/*'
  s.requires_arc = true

end