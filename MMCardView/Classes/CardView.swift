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
        
        dispatch_async(dispatch_get_main_queue()) {
            var removeIdx = [Int]()
            var insertIdx = [Int]()
            for (idx,value) in self.cardArr.enumerate() {
                let rc = isInclued(idx,value)
                
                if !rc && self.filterSet.contains(idx) {
                    let i = self.filterSet.indexOf(idx)!
                    removeIdx.append(i)
                } else if rc && !self.filterSet.contains(idx){
                    insertIdx.append(idx)
                }
            }
            
            self.filterArr = self.filterArr.enumerate().filter { !removeIdx.contains($0.index)}.map {$0.element}
            self.filterSet = self.filterSet.enumerate().filter { !removeIdx.contains($0.index)}.map {$0.element}
            let removePaths = removeIdx.map { NSIndexPath.init(forRow: $0, inSection: 0) }
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItemsAtIndexPaths(removePaths)
            }) { (finish) in
                var add = self.filterSet + insertIdx
                var insertPath = [NSIndexPath]()
                if insertIdx.count > 0 {
                    insertPath += Array(self.filterSet.count...add.count-1).map {NSIndexPath.init(forRow: $0, inSection: 0)}
                }
                self.filterArr = add.map {self.cardArr[$0]}
                self.filterSet = add
                
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItemsAtIndexPaths(insertPath)
                    
                    }, completion: { (finish) in
                        if insertIdx.count == 0 {
                            return
                        }
                        
                        add = add.enumerate().sort {$0.0.element < $0.1.element}.map {$0.element}
                        
                        let value:[(NSIndexPath,NSIndexPath)] = self.filterSet.enumerate().map {
                            let from = NSIndexPath.init(forRow: $0.index, inSection: 0)
                            let to = NSIndexPath.init(forRow: add.indexOf($0.element)!, inSection: 0)
                            return (from , to)
                        }
                        self.filterSet = add
                        self.filterArr = add.map {self.cardArr[$0]}
                        
                        self.collectionView.performBatchUpdates({
                            for (from,to) in value {
                                print ("From :\(from.row) To : \(to.row)")
                                let  cell = self.collectionView.cellForItemAtIndexPath(from)
                                cell?.layer.zPosition = CGFloat(to.row)
                                self.collectionView.moveItemAtIndexPath(from, toIndexPath: to)
                            }
                            }, completion:nil)
                        
                })
            }
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
