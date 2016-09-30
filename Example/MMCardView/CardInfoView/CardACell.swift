//
//  CardACell.swift
//  MMCardView
//
//  Created by MILLMAN on 2016/9/21.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit
import MMCardView

class CardACell: CardCell,CardCellProtocol {
    @IBOutlet weak var labTitle:UILabel!
    @IBOutlet weak var txtView:UITextView!
    
    public static func cellIdentifier() -> String {
        return "CardA"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
