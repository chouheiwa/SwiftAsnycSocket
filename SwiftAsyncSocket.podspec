Pod::Spec.new do |s|
  s.swift_version = "4.2"
  s.name         = "SwiftAsyncSocket"
  s.version      = "0.0.1"
  s.summary      = "A GCD base of Socket writing by Swift 4.2"
  s.description  = <<-DESC
A socket connection tool writing by Swift.
It has has the same function with CocoaAsyncSocket
                   DESC

  s.homepage     = "https://github.com/chouheiwa/SwiftAsnycSocket"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "chouheiwa" => "849131492@qq.com" }
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/chouheiwa/SwiftAsnycSocket.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*"
  s.exclude_files = "Sources/**/*.plist"
end
