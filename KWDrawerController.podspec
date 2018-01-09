Pod::Spec.new do |s|

  s.name              = 'KWDrawerController'
  s.version           = '4.1'
  s.summary           = 'Drawer view controller that easy to use!'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage          = 'https://github.com/kawoou/KWDrawerController'
  s.authors           = { 'Jungwon An' => 'kawoou@kawoou.kr' }
  s.social_media_url  = 'http://fb.com/kawoou'
  s.platform          = :ios
  s.source            = { :git => 'https://github.com/kawoou/KWDrawerController.git', :tag => 'v' + s.version.to_s }

  s.frameworks        = 'QuartzCore'
  s.module_name       = 'KWDrawerController'
  s.requires_arc      = true

  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'DrawerController/Types/*.swift',
                      'DrawerController/Models/*.swift',
                      'DrawerController/View/*.swift',
                      'DrawerController/Animator/*.swift',
                      'DrawerController/Transition/*.swift',
                      'DrawerController/*.swift',
                      'DrawerController/Segue/*.swift'
  end
  
  s.subspec 'RxSwift' do |ss|
    ss.source_files = 'DrawerController/Rx/*.swift'
    ss.dependency "KWDrawerController/Core"
    ss.dependency "RxSwift", ">= 4.0.0"
    ss.dependency "RxCocoa", ">= 4.0.0"
  end

end
