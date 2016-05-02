//
//  MainTableViewCellController.swift
//  FoodInMyFridge
//
//  Created by Teo Pavlov on 4/18/16.
//  Copyright © 2016 ANCoders. All rights reserved.
//

import UIKit

class MainTableViewCellController: UITableViewCell {

    @IBOutlet weak var FoodImage: UIImageView!
    @IBOutlet weak var ExpirationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        //FoodImage.layer.borderWidth = 1
        //FoodImage.layer.borderColor = UIColor.redColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
