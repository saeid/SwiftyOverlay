# SwiftyOverlay
A component to show instructions and info on UI at run time with easy to setup and customizable API.

Supported Components are : `UITabbarItem`, `TableView`, `TabbarView`, all `UIView` controls and components!

For demo project check [this repo](https://github.com/saeid/SwiftyGuideOverlay)

![2](https://cloud.githubusercontent.com/assets/9967486/21859393/a6fbe282-d841-11e6-9271-e0e9e9c6bb6c.gif)
![1](https://cloud.githubusercontent.com/assets/9967486/21859399/ac3822a6-d841-11e6-9272-64c553630e1c.gif)


## Requirements
- Xcode 9+
- Swift 4+
- iOS 9+


## Installation

## Swift Package Manager

```swift
.package(url: "https://github.com/saeid/SwiftyOverlay.git", from: "1.1.14")
```

## Cocoapods

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'SwiftyOverlay'
end
```
    pod update 
    pod install

## Usage

Inherit `SkipOverlayDelegate`
```swift
class ViewController: UIViewController, SkipOverlayDelegate
```

Create an instance of GDOverlay
```swift
var overlay: GDOverlay = GDOverlay()
```

Set delegate
```swift
overlay.delegate = self
```

Set properties
```swift 
overlay.arrowColor = UIColor.red
overlay.arrowWidth = 2.0
overlay.lineType = LineType.line_bubble

...

// Full properties list can be found on sample project

```

Now call Overlay View Skip function to show!
```swift
onSkipSignal()
```

Override `onSkipSignal` function
```swift
func onSkipSignal(){
    /// Add an attributed string over the screen
    overlay.drawOverlay(desc: NSMutableAttributedString)

    /// TableView
    overlay.drawOverlay(to: self.tableView, section: 0, row: 0, desc: "Description ...")
    
    /// UIBarButtonItem
    overlay.drawOverlay(to: barButtonItem, desc: "Description ...")

    /// Any other views
    overlay.drawOverlay(to: self.someView, desc: "Description ...", isCircle: true)
    
    /// TabBar Items
    overlay.drawOverlay(to: self.tabbarView, item: 0, desc: "Description ...")
    
    /// For StackViews, Eg. first view of stackview
    let targetView = stackView.arrangedSubviews[0]
    o.drawOverlay(to: targetView, desc: "Description ...", isCircle: true)
}
```

## Licence
SwiftyHelpOverlay is available under the MIT license. See the [LICENSE.txt](https://github.com/SaeidBsn/SwiftyGuideOverlay/blob/master/Licence.txt) file for more info.

