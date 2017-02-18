Pod::Spec.new do |s|

  s.name         = "KWDrawerController"
  s.version      = "3.0"
  s.summary      = "Drawer view controller that easy to use!"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.homepage     = "https://github.com/Kawoou/KWDrawerController"
  s.authors      = { "Jungwon An" => "kawoou@kawoou.kr" }
  s.social_media_url   = "http://fb.com/kawoou"
  s.platform     = :ios
  s.source       =  { :git => "https://github.com/Kawoou/KWDrawerController.git",
                      :tag => s.version.to_s }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.source_files = 'DrawerController/Types/*.swift',
                   'DrawerController/Models/*.swift',
                   'DrawerController/View/*.swift',
                   'DrawerController/Animator/*.swift',
                   'DrawerController/Transition/*.swift',
                   'DrawerController/*.swift',
                   'DrawerController/Segue/*.swift'

  s.framework  = 'QuartzCore'

end
