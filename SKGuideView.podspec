Pod::Spec.new do |s|
s.name = "SKGuideView"
s.version = "1.1"
s.ios.deployment_target = '6.0'
s.summary = "Automatic-Guidance"
s.homepage = "https://github.com/macios/SKGuideView"
s.license = 'MIT'
s.authors = { "SK" => "nil.com" }
s.source = { :git => "https://github.com/macios/SKGuideView.git", :tag => "1.1" }
s.frameworks = 'UIKit'
s.source_files = 'SKGuideView/**/GuideView/*.{h,m,png}'
s.resources = 'SKGuideView/**/GuideView/*.png'
s.requires_arc = true
end