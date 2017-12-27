Pod::Spec.new do |s|

  s.name         = "YIFNestScrollTableView"
  s.version      = "0.0.1"
  s.summary      = "nest scroll tableView"

  s.description  = <<-DESC
                   YIFNestScrollTableView used on iOS, which implement by Objective-C
                   DESC

  s.homepage     = "https://github.com/yifzone/YIFNestScrollTableView"
  s.license      = "MIT"
  s.author       = { "yifzone" => "yifzone@126.com" }
  s.platform     = :ios,'8.0'

  s.source       = { :git => "https://github.com/yifzone/YIFNestScrollTableView.git", :tag => "#{s.version}" }
  s.source_files = "YIFNestScrollTableView/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = true
end