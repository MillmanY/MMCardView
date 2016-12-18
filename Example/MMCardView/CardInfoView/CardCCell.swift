//
//  CardCCell.swift
//  MMCardView
//
//  Created by MILLMAN on 2016/9/21.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import MMCardView
class CardCCell: CardCell,CardCellProtocol {
    @IBOutlet weak var btnClick:UIButton!
    private var callBack:(()->Void)?
    public static func cellIdentifier() -> String {
        return "CardC"
    }

    func clickCallBack(c:@escaping ()->Void) {
        self.callBack = c
    }
    
    @IBAction func clickAction() {
        if let c = self.callBack {
            c()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
