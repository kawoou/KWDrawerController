Pod::Spec.new do |s|
  s.name                = "KWDrawerController"
  s.version             = "2.2"
  s.summary             = "Drawer view controller that easy to use!"
  s.homepage            = "http://github.com/Kawoou/KWDrawerController"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Kawoou" => "kawoou@kawoou.kr" }
  s.source              = { :git => "https://github.com/Kawoou/KWDrawerController.git", :tag => "#{s.version}" }
  s.platform            = :ios, 7.0
  s.public_header_files = 'KWDrawerController/KWDrawerController/KWDrawer.h'
  s.frameworks          = 'UIKit', 'Foundation', 'QuartzCore'
  s.requires_arc        = true
  s.source_files        = 'KWDrawerController/KWDrawerController/*', 'KWDrawerController/KWDrawerController/Animation/*'
end
