//
//  CardView.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

public protocol CardCollectionViewDataSource:class {
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:NSIndexPath) -> UICollectionViewCell
}

public class CardView: UIView {
    public weak var cardDataSource:CardCollectionViewDataSource?
    
    private var isFilterMode = false

    private var filterSet = [Int]()
    private var filterArr = [AnyObject]()
    private var cardArr = [AnyObject]() {
        didSet {
            self.collectionView.reloadData()
            if cardArr.count > 0 {
                filterSet = Array(0...cardArr.count-1)
            }
            filterArr.removeAll()
            filterArr += cardArr
        }
    }
    private var transition = CustomFlipTransition(duration: 0.3)
    private lazy var collectionView:UICollectionView = {
        let layout = CustomCardLayout()
        let c = UICollectionView.init(frame: self.frame, collectionViewLayout: layout)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.delegate = self
        c.dataSource = self
        c.backgroundColor = UIColor.clearColor()
        return c
    }()
    
    private func setUp() {
        self.addSubview(collectionView)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let left = NSLayoutConstraint.init(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: collectionView.superview!, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint.init(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: collectionView.superview!, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint.init(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: collectionView.superview!, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint.init(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: collectionView.superview!, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.addConstraints([left,right,top,bottom])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }

    public func set(cards:[AnyObject]) {
        cardArr.removeAll()
        cardArr += cards
    }
    
    public func filterAllDataWith(isInclued:(Int,AnyObject) -> Bool) {
        var removeIdx = [Int]()
        var insertIdx = [Int]()
        
        for (idx,value) in cardArr.enumerate() {
            let rc = isInclued(idx,value)
            
            if !rc && filterSet.contains(idx) {
                let i = filterSet.indexOf(idx)!
                removeIdx.append(i)
            } else if rc && !filterSet.contains(idx){
                insertIdx.append(idx)
            }
        }
        
        filterArr = filterArr.enumerate().filter { !removeIdx.contains($0.index)}.map {$0.element}
        filterSet = filterSet.enumerate().filter { !removeIdx.contains($0.index)}.map {$0.element}
        let removePaths = removeIdx.map { NSIndexPath.init(forRow: $0, inSection: 0) }
        self.collectionView.performBatchUpdates({
                self.collectionView.deleteItemsAtIndexPaths(removePaths)
            }) { (finish) in
                self.filterSet += insertIdx
                self.filterSet.enumerate().sort({ (value2, value1) -> Bool in
                    
                    let isSort = (value1.element > value2.element)
                    return isSort

                }).map {$0.element }
                                
                self.filterArr = self.cardArr.enumerate().filter({ (idx,value) -> Bool in
                    return self.filterSet.contains(idx)
                }).map({ (idx,value) -> AnyObject in
                    return value
                })
                
                let insertPath = insertIdx.map {NSIndexPath.init(forRow: self.filterSet.indexOf( $0)!, inSection: 0)}

                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItemsAtIndexPaths(insertPath)
                    }, completion: { (finish) in
                })
        }
    }
    
    public func showAllData() {
        self.filterAllDataWith { _,_ in true}
    }
    
    public func showStyle(style:SequenceStyle) {
    
        dispatch_async(dispatch_get_main_queue()) { 
            if let custom = self.collectionView.collectionViewLayout as? CustomCardLayout {
                custom.showStyle = style
            }
        }
    }
    
    public func presentViewController(to vc:UIViewController) {
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout  where custom.selectIdx == -1{
            print ("You nees Select a cell")
            return
        }

        let current = UIViewController.currentViewController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .Custom
        current.presentViewController(vc, animated: true, completion: nil)
    }

    public func registerCardCell(c:AnyClass,nib:UINib) {
        if (c.alloc().isKindOfClass(CardCell.classForCoder())) {
            
            let identifier = c.valueForKey("cellIdentifier") as! String
            collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
        } else {
            NSException(name: NSExceptionName(string: "Cell type error!!") as String, reason: "Need to inherit CardCell", userInfo: nil).raise()
        }
    }
    
    public func expandBottomCount(count:Int) {
        if let layout = self.collectionView.collectionViewLayout as? CustomCardLayout {
            layout.bottomShowCount = count
        }
    }

}

extension CardView:UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
            custom.selectIdx = indexPath.row
        }
    }
}

extension CardView:UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterArr.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let source = cardDataSource?.cardView(collectionView, item: filterArr[indexPath.row], indexPath: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        source.collectionV = collectionView
        source.reloadBlock = {
            if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
                custom.selectIdx = indexPath.row
            }
        }
        source.hidden = false
        return source
    }
}

extension CardView:UIViewControllerTransitioningDelegate{

    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
   
        transition.transitionMode = .Present
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
            transition.cardView = self.collectionView.cellForItemAtIndexPath(NSIndexPath.init(forRow: custom.selectIdx, inSection: 0))
            
            custom.isFullScreen = true
        }
        return transition
    }

    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .Dismiss
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
            custom.isFullScreen = false
        }
        return transition
    }
}
