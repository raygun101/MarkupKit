Pod::Spec.new do |s|
  s.name             = 'MarkupKit'
  s.version          = '2.5'
  s.summary          = 'Declarative UI for iOS applications'
  s.description      = <<-DESC
    MarkupKit is a framework for simplifying development of native iOS applications. It allows
    developers to construct user interfaces declaratively using a human-readable markup language,
    rather than programmatically in code or interactively using a visual modeling tool such as
    Interface Builder.
    DESC
  s.homepage         = 'https://github.com/gk-brown/MarkupKit'
  s.license          = 'Apache License, Version 2.0'
  s.author           = 'Greg Brown'
  s.source           = { :git => "https://github.com/gk-brown/MarkupKit.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'MarkupKit/*.{h,m}'
end
