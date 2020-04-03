Pod::Spec.new do |spec|

  spec.name         = "RXCPageView"
  spec.version      = "1.0"
  spec.summary      = "A simple page view"
  spec.description  = "A simple page view"
  spec.homepage     = "https://github.com/ruixingchen/RXCPageView"
  spec.license      = "MIT"

  spec.author       = { "ruixingchen" => "rxc@ruixingchen.com" }
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/ruixingchen/RXCPageView.git", :tag => spec.version.to_s }
  spec.source_files  = "Source/**/*.{swift}"
  spec.framework = "UIKit"

  spec.requires_arc = true
  spec.swift_versions = "5.1"

end