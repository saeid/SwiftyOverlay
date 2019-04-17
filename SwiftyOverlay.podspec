Pod::Spec.new do |s|
s.name             = "SwiftyOverlay"
s.version          = "1.1.5"
s.summary          = "App showcase and runtime tour"
s.homepage         = "https://github.com/saeid/SwiftyOverlay"
s.license          = 'MIT'
s.author           = { "Saeid Basirnia" => "saeid.basirniaa@gmail.com" }
s.source           = { :git => "https://github.com/saeid/SwiftyOverlay.git", :tag => "1.1.5"}

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
s.platform     = :ios
s.ios.deployment_target  = '9.0'
s.requires_arc = true
s.swift_version = '5.0'
s.source_files = 'SwiftyOverlay/**/*.{swift}'
s.frameworks = 'UIKit'

end


