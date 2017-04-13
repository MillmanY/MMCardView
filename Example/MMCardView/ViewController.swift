//
//  ViewController.swift
//  MMCardView
//
//  Created by Millman on 09/20/2016.
//  Copyright (c) 2016 Millman. All rights reserved.
//

import UIKit
import MMCardView
class ViewController: UIViewController,CardCollectionViewDataSource {
    
    @IBOutlet weak var card:CardView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        card.registerCardCell(c: CardACell.classForCoder(), nib: UINib.init(nibName: "CardACell", bundle: nil))
        card.registerCardCell(c: CardBCell.classForCoder(), nib: UINib.init(nibName: "CardBCell", bundle: nil))
        card.registerCardCell(c: CardCCell.classForCoder(), nib: UINib.init(nibName: "CardCCell", bundle: nil))
        card.cardDataSource = self
        let arr = self.generateCardInfo(cardCount: 10)
        card.set(cards: arr)
        
        self.card.showStyle(style: .cover)
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func generateCardInfo (cardCount:Int) -> [AnyObject] {
        var arr = [AnyObject]()
        let xibName = ["CardA","CardB","CardC"]
        
        for _ in 1...cardCount {
            let value = Int(arc4random_uniform(3))
            arr.append(xibName[value] as AnyObject)
        }

        return arr
    }
    
    func cardView(collectionView:UICollectionView,item:AnyObject,indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item as! String, for: indexPath )
        switch cell {
            case let c as CardACell:
                c.txtView.text = "Hello This is MMCardView ,Its a demo with different Card Type,This is a text type"
            case let c as CardBCell:
                let v = Int(arc4random_uniform(5))+1
                c.imgV.image = UIImage.init(named: "image\(v)")            
            case let c as CardCCell:
                c.clickCallBack {
                    if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Second") as? SecondViewController {
                        vc.delegate = self
                        self.card.presentViewController(to: vc)
                    }
                }
            default:
                return UICollectionViewCell()

        }
        return cell
    }
    
    @IBAction func segmentAction(seg:UISegmentedControl) {
        if (seg.selectedSegmentIndex == 0) {
            self.card.showStyle(style: .cover)
        } else {
            self.card.showStyle(style: .normal)
        }
    }
    
    @IBAction func filterAction () {
        let sheet = UIAlertController.init(title: "Filter", message: "Select you want to show in View", preferredStyle: .actionSheet)

        let cellA = UIAlertAction(title: "CellA", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardA"
            })
        })
        
        let cellB = UIAlertAction(title: "CellB", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardB"
            })
        })
        
        let cellC = UIAlertAction(title: "CellC", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return (obj as! String) == "CardC"
            })
        })
        let ac = ["CardA","CardC"]
        let cellAC = UIAlertAction(title: "CellA,CellC", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            self.card.filterAllDataWith(isInclued: { (idex, obj) -> Bool in
                return ac.contains(obj as! String)
            })
        })
        
        let allCell = UIAlertAction(title: "CellAll", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
           self.card.showAllData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
                
        sheet.addAction(cellA)
        sheet.addAction(cellB)
        sheet.addAction(cellC)
        sheet.addAction(cellAC)

        sheet.addAction(allCell)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:SecondViewProtocol {
    func removeCard() {
       card.removeSelectCard()
    }
}

