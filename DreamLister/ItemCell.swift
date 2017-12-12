//
//  ItemCell.swift
//  DreamLister
//
//  Created by Fareen on 11/7/17.
//  Copyright © 2017 Fareen. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var thumbImg: UIImageView!
    
    func configureCell(item: Item) {
        titleLbl.text = item.title?.capitalized
        priceLbl.text = "$\(item.price)"
        detailsLbl.text = item.details
        thumbImg.image = item.toImage?.image as? UIImage
    }
}
