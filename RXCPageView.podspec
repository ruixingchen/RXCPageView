Pod::Spec.new do |spec|

  spec.name         = "RXCPageView"
  spec.version      = "2.0"
  spec.summary      = "yes, a scrollable page view"
  spec.description  = "yes, a scrollable page view"
  spec.homepage     = "https://github.com/ruixingchen/RXCPageView"
  spec.license      = "MIT"

  spec.author       = { "ruixingchen" => "rxc@ruixingchen.com" }
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/ruixingchen/RXCPageView.git", :tag => spec.version.to_s }

  spec.requires_arc = true
  spec.swift_versions = "5.1"

  spec.default_subspecs = 'Core'

  spec.subspec 'Core' do |core|
    core.source_files = ['Source/Core/**/*.{swift, h, m, mm}']
  end

  spec.subspec 'PageViewController' do |subspec|
    subspec.dependency 'RXCPageView/Core'
    subspec.source_files = ['Source/PageViewController/**/*.{swift, h, m, mm}']
  end

end