#
#  Be sure to run `pod spec lint STMPersistance.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "STMPersistance"
  s.version      = "1.0"
  s.summary      = "基于 sqlite 的持久化存储"
  s.homepage     = "https://github.com/DouKing/STMPersistance"
  s.license      = "MIT"
  s.author       = { "wuyikai" => "wyk8916@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/DouKing/STMPersistance.git", :tag => "#{s.version}" }
  s.source_files = "STMPersistance/STMPersistance/**/*.{h,m}"
  s.requires_arc = true
  s.dependency     "STMRecord"
  s.dependency     "FMDB"

end
