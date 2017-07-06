platform :ios, '9.0'

use_frameworks!

target 'UpsalesTestApp' do
    pod 'Alamofire', '~> 4.3'
    pod 'DATASource'
    pod 'FontAwesome.swift'
    pod 'MBProgressHUD'
    pod 'MMDrawerController'
    pod 'MMDrawerController+Storyboard'
    pod 'Sync'
end

target 'UpsalesTestAppTests' do
    pod 'Alamofire', '~> 4.3'
    pod 'DATASource'
    pod 'FontAwesome.swift'
    pod 'MBProgressHUD'
    pod 'MMDrawerController'
    pod 'MMDrawerController+Storyboard'
    pod 'Sync'
end

target 'UpsalesTestAppUITests' do
    pod 'Alamofire', '~> 4.3'
    pod 'DATASource'
    pod 'FontAwesome.swift'
    pod 'MBProgressHUD'
    pod 'MMDrawerController'
    pod 'MMDrawerController+Storyboard'
    pod 'Sync'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
