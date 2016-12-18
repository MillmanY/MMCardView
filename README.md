# MMCardView

[![CI Status](http://img.shields.io/travis/Millman/MMCardView.svg?style=flat)](https://travis-ci.org/Millman/MMCardView)
[![Version](https://img.shields.io/cocoapods/v/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)
[![License](https://img.shields.io/cocoapods/l/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)
[![Platform](https://img.shields.io/cocoapods/p/MMCardView.svg?style=flat)](http://cocoapods.org/pods/MMCardView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Demo

![demo](https://github.com/MillmanY/MMCardView/blob/master/demo.gif)


## Requirements

    iOS 8.0+
    Xcode 8.0+
    Swift 3.0+
## Use
1.Register your CollectionView Cell and Datasource
    
    card.cardDataSource = self
    card.registerCardCell(c: CardACell.classForCoder(), nib: UINib.init(nibName: "CardACell", bundle: nil))
2.Set your data use

    card.set(cards: arr)
    
3.Create your Cell inherit "CardCell" and implement "CardCellProtocol"

    class CardACell: CardCell,CardCellProtocol {
       
       // Set your Cell Identifier
       public static func cellIdentifier() -> String {
            return "CardA"
        }
    }
4.Handle Datasource
    
    item : What you put in Step 2
  
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item as! String, for: indexPath )
        return cell
    }
    
## Style

     public enum SequenceStyle:Int {
       case normal
       case cover
     }
## Filter
1.Hide you dont want to show use function

    card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
         return (obj as! String) == "CardA"
    })
2.Show All Data

    card.showAllData()
## Other

1.BottomCount when Expand

    card.expandBottomCount(count:Int)
2.Flip ViewController

    card.presentViewController(to: vc)
3.Set show height for every cell (Default is 56.0)

    card.setCardTitleHeight(heihgt: 56)
4.Set Card Height (Defualt is Screen 85%)

    card.setCardHeight(height:100)
5.Remove Card

    card.removeCard(at index:0)
    card.removeSelectCard()  
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
