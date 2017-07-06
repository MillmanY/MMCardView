//
//  ViewController.swift
//  MMCardView
//
//  Created by Millman on 09/20/2016.
//  Copyright (c) 2016 Millman. All rights reserved.
//

import UIKit
import MMCardView
class ViewController: UIViewController {
    var sectionData = [["CardA","CardB","CardC"],["CardB","CardB","CardB"],["CardC"],["CardD"]]
    @IBOutlet weak var cardCollection: MMCollectionView!
    @IBOutlet weak var banner:MMCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = banner.collectionViewLayout as? BannerLayout {
            layout.itemSpace = 5.0
            layout.itemSize = self.banner!.frame.insetBy(dx: 30, dy: 5).size
//            layout.itemEdge = UIEdgeInsets(top: 10, left: 2.5, bottom: 2.5, right: 10)
        }
        
        (banner.collectionViewLayout as? BannerLayout)?.isInfinite = true
        cardCollection.register(UINib(nibName: "CardACell", bundle: nil), forCellWithReuseIdentifier: "CardA")
        cardCollection.register(UINib(nibName: "CardBCell", bundle: nil), forCellWithReuseIdentifier: "CardB")
        cardCollection.register(UINib(nibName: "CardCCell", bundle: nil), forCellWithReuseIdentifier: "CardC")
        
        if let layout = cardCollection.collectionViewLayout as? CustomCardLayout {
            layout.titleHeight = 100.0
            layout.bottomShowCount = 3
            layout.cardHeight = 300
            layout.showStyle = .cover
        }
    }
    @IBAction func segmentAction(seg:UISegmentedControl) {
        if (seg.selectedSegmentIndex == 0) {
            (cardCollection.collectionViewLayout as?  CustomCardLayout)?.showStyle = .cover
        } else {
            (cardCollection.collectionViewLayout as?  CustomCardLayout)?.showStyle = .normal
        }
    }
    
    @IBAction func filterAction () {
        let sheet = UIAlertController.init(title: "Filter", message: "Select you want to show in View", preferredStyle: .actionSheet)
        
        let removeA = UIAlertAction(title: "Remove A", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if self.sectionData[0].count == 0 {
                return
            }
            self.sectionData[0].removeFirst()
            self.cardCollection.deleteItems(at: [IndexPath.init(row: 0, section: 0)])
        })
        
        let removeB = UIAlertAction(title: "Remove B", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.sectionData[1].count == 0 {
                return
            }

            self.sectionData[1].removeFirst()
            self.cardCollection.deleteItems(at: [IndexPath.init(row: 0, section: 1)])
        })
        
        let removeC = UIAlertAction(title: "Remove C", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.sectionData[2].count == 0 {
                return
            }

            self.sectionData[2].removeFirst()
            self.cardCollection.deleteItems(at: [IndexPath(row: 0, section: 2)])
        })
        let appendA = UIAlertAction(title: "Append 2 A items", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sectionData[0].insert("CardA", at: 0)
            self.sectionData[0].insert("CardA", at: 0)

            self.cardCollection.insertItems(at: [IndexPath(row: 0, section:0),
                                                 IndexPath(row: 1, section:0)])
        })
        
        let appendB = UIAlertAction(title: "Append B", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sectionData[1].insert("CardB", at: 0)
            self.cardCollection.insertItems(at: [IndexPath.init(row: 0, section:1)])
        })
        let appendC = UIAlertAction(title: "Append C", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sectionData[2].insert("CardC", at: 0)
            self.cardCollection.insertItems(at: [IndexPath.init(row: 0, section:2)])
        })
        
        sheet.addAction(removeA)
        sheet.addAction(removeB)
        sheet.addAction(removeC)
        sheet.addAction(appendA)
        sheet.addAction(appendB)
        sheet.addAction(appendC)
        self.present(sheet, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionData[section].count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == banner {
            return self.banner(collectionView: collectionView, cellForItemAt: indexPath)
        } else if collectionView == cardCollection {
            return self.card(collectionView: collectionView, cellForItemAt: indexPath)
        }
        return UICollectionViewCell()
    }
    
    
    fileprivate func banner(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerViewCell", for: indexPath)

        if indexPath.section == 0 && indexPath.row == 0{
            (cell as? BannerViewCell)?.imgView.image = #imageLiteral(resourceName: "image1")
        } else {
            (cell as? BannerViewCell)?.imgView.image = #imageLiteral(resourceName: "image4")
        }
        return cell
    }
    
    fileprivate func card(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let idenTifier = sectionData[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idenTifier, for: indexPath)
        switch cell {
        case let c as CardCCell:
            
            c.clickCallBack {
                if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Second") as? SecondViewController {
                    vc.delegate = self
                    //                    (self.cardCollection.collectionViewLayout as? CustomCardLayout)?.isFullScreen = true
                    self.cardCollection.presentViewController(to: vc)
                }
            }
        case let c as CardBCell:
            c.imgV.image = #imageLiteral(resourceName: "image1")
        default:
            break
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension ViewController:SecondViewProtocol {
    func removeCard() {
        
        if let layout = self.cardCollection.collectionViewLayout as? CustomCardLayout , let path = layout.selectPath {
            sectionData[path.section].remove(at: path.row)
            cardCollection.deleteItems(at: [path])
        }
//       card.removeSelectCard()
    }
}

