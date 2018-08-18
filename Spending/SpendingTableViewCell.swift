//
//  SpendingTableViewCell.swift
//  Spending
//
//  Created by Chi Yu on 8/3/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

class SpendingTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
