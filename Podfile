# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Papaya' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Papaya
  
  #ReactiveX
  pod 'RxSwift', '~> 4.0'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'RxSwift'
              target.build_configurations.each do |config|
                  if config.name == 'Debug'
                      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                  end
              end
          end
      end
  end
  
  #UI
  pod 'SnapKit', '~> 4.0.0'
  
  #Custom Controls / Views
  pod 'CHIPageControl/Jaloro'
  pod 'JVFloatLabeledTextField'
  pod 'TOMSMorphingLabel', '~> 0.5'
  pod 'PMAlertController'
  pod 'DSGradientProgressView'
  
  #HTTP
  pod 'SwiftyJSON'
  pod 'SocketRocket'
  pod 'PINRemoteImage'

  #Animations
  pod 'Hero', '1.0.0-alpha.4'
  
  #Security
  pod 'KeychainAccess'
  
end
