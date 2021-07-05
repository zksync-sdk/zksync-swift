//
//  DepositingBalanceTableViewCell.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 08/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class DepositingBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var blockNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
