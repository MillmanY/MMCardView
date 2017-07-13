# MMCardView

[![CI Status](http://img.shields.io/travis/Millman/MMCardView.svg?style=flat)](https://travis-ci.org/Millman/MMCardView)
[![Version](https://img.shields.io/cocoapods/v/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)
[![License](https://img.shields.io/cocoapods/l/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)
[![Platform](https://img.shields.io/cocoapods/p/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Demo
1.Card

![demo](https://github.com/MillmanY/MMCardView/blob/master/demo.gif)


## Requirements

    iOS 8.0+
    Xcode 8.0+
    Swift 3.0+
## Use Card
1.Inherit your collectionView to MMCollectionView
       
    @IBOutlet weak var cardCollection: MMCollectionView!
    
2.Create your Cell inherit "CardCell"

    class CardACell: CardCell {

    }

    if let layout = cardCollection.collectionViewLayout as? CustomCardLayout {
         layout.titleHeight = 100.0
         layout.bottomShowCount = 3
         layout.cardHeight = 300
         layout.showStyle = .cover
    }
## Installation

MMCardView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
Swift 3
pod 'MMCardView'
Swift2.3
pod 'MMCardView',:git => 'https://github.com/MillmanY/MMCardView', :branch => ‘Swift2’

```

## Author

Millman, millmanyang@gmail.com

## License

MMCardView is available under the MIT license. See the LICENSE file for more info.
