Pod::Spec.new do |s|
  s.name            = 'MarkupKit'
  s.version         = '4.5'
  s.license         = 'Apache License, Version 2.0'
  s.homepage        = 'https://github.com/gk-brown/MarkupKit'
  s.author          = 'Greg Brown'
  s.summary         = 'Declarative UI for iOS and tvOS'
  s.source          = { :git => "https://github.com/gk-brown/MarkupKit.git", :tag => s.version.to_s }

  s.ios.deployment_target   = '10.0'
  s.ios.source_files        = 'MarkupKit-iOS/MarkupKit/*.{h,m}'
  s.tvos.deployment_target  = '10.0'
  s.tvos.source_files       = 'MarkupKit-iOS/MarkupKit/*.{h,m}'
end
