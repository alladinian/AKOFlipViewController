#
# Be sure to run `pod lib lint AKOFlipViewController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AKOFlipViewController"
  s.version          = "0.1.2"
  s.summary          = "A Flip-Style View Controller"
  s.description      = <<-DESC
                        A Flip-Style View Controller with 2.5D animations and shadows.
                       DESC
  s.homepage         = "https://github.com/alladinian/AKOFlipViewController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Vasilis Akoinoglou" => "alladinian@gmail.com" }
  s.source           = { :git => "https://github.com/alladinian/AKOFlipViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/alladinian'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  # s.resources = 'Pod/Assets/*.png'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
