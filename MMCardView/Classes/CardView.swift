//
//  CardView.swift
//  Pods
//
//  Created by MILLMAN on 2016/9/20.
//
//

import UIKit

public protocol CardCollectionViewDataSource:class {
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell
}

public class CardView: UIView {
    public weak var cardDataSource:CardCollectionViewDataSource?
    
    fileprivate var isFilterMode = false

    fileprivate var filterSet = [Int]()
    fileprivate var filterArr = [AnyObject]()
    fileprivate var cardArr = [AnyObject]() {
        didSet {
            self.collectionView.reloadData()
            if cardArr.count > 0 {
                filterSet = Array(0...cardArr.count-1)
            }
            filterArr.removeAll()
            filterArr += cardArr
        }
    }
    fileprivate var transition = CustomFlipTransition(duration: 0.3)
    fileprivate lazy var collectionView:UICollectionView = {
        let layout = CustomCardLayout()
        let c = UICollectionView.init(frame: self.frame, collectionViewLayout: layout)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.delegate = self
        c.dataSource = self
        c.backgroundColor = UIColor.clear
        return c
    }()
    
    fileprivate func setUp() {
        self.addSubview(collectionView)
        self.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: collectionView.superview!, attribute: .left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint.init(item: collectionView, attribute: .right, relatedBy: .equal, toItem: collectionView.superview!, attribute: .right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: collectionView.superview!, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint.init(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: collectionView.superview!, attribute: .bottom, multiplier: 1.0, constant: 0.0)
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
    
    public func filterAllDataWith(isInclued:@escaping (Int,AnyObject) -> Bool) {
        var removeIdx = [Int]()
        var insertIdx = [Int]()
        
        for (idx,value) in cardArr.enumerated() {
            let rc = isInclued(idx,value)
            
            if !rc && filterSet.contains(idx) {
                let i = filterSet.index(of: idx)!
                removeIdx.append(i)
            } else if rc && !filterSet.contains(idx){
                insertIdx.append(idx)
            }
        }
        
        filterArr = filterArr.enumerated().filter { !removeIdx.contains($0.offset)}.map {$0.element}
        filterSet = filterSet.enumerated().filter { !removeIdx.contains($0.offset)}.map {$0.element}

        let removePaths = removeIdx.map { IndexPath.init(row: $0, section: 0) }
        self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: removePaths)
            }) { (finish) in
                let isReload = (self.filterArr.count == 0)
                self.filterSet += insertIdx
                self.filterSet = self.filterSet.enumerated().sorted(by: { (value2, value1) -> Bool in
                    let isSort = (value1.element > value2.element)
                    return isSort
                }).map {$0.element }
                
                self.filterArr = self.cardArr.enumerated().filter({ (idx,value) -> Bool in
                    return self.filterSet.contains(idx)
                }).map({ (idx,value) -> AnyObject in
                    return value
                })

                let insertPath = insertIdx.map {IndexPath.init(row: self.filterSet.index(of: $0)!, section: 0)}

                self.collectionView.performBatchUpdates({ 
                    self.collectionView.insertItems(at: insertPath)
                    }, completion: { (finish) in
                })
        }
    }
    
    public func showAllData() {
        self.filterAllDataWith { _,_ in true}
    }
    
    public func showStyle(style:SequenceStyle) {
        DispatchQueue.main.async { 
            if let custom = self.collectionView.collectionViewLayout as? CustomCardLayout {
                custom.showStyle = style
            }            
        }
    }
    
    public func presentViewController(to vc:UIViewController) {
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout ,custom.selectIdx == -1{
            print ("You nees Select a cell")
            return
        }

        let current = UIViewController.currentViewController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        current.present(vc, animated: true, completion: nil)
    }

    public func registerCardCell(c:AnyClass,nib:UINib) {
        if (c.alloc().isKind(of: CardCell.classForCoder())) {
            let identifier = c.value(forKey: "cellIdentifier") as! String
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            NSException(name: NSExceptionName(rawValue: "Cell type error!!"), reason: "Need to inherit CardCell", userInfo: nil).raise()
        }
    }

}

extension CardView:UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        guard let source = cardDataSource?.cardView(collectionView: collectionView,item: filterArr[indexPath.row], indexPath: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        source.collectionV = collectionView
        source.reloadBlock = {
            if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
                custom.selectIdx = indexPath.row
            }
        }
        source.isHidden = false
        return source
    }
}

extension CardView:UIViewControllerTransitioningDelegate{

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
            transition.cardView = self.collectionView.cellForItem(at: IndexPath.init(row: custom.selectIdx, section: 0))
            custom.isFullScreen = true
        }
        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        if let custom = collectionView.collectionViewLayout as? CustomCardLayout {
            custom.isFullScreen = false
        }
        return transition
    }
}
