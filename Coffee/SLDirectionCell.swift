//
//  SLDirectionCell.swift
//  Coffee
//
//  Created by Saumya Lahera on
//

import UIKit


class SLDirectionCell: UITableViewCell {

    /*@IBOutlet var duration:UILabel!
    @IBOutlet var distance:UILabel!
    @IBOutlet var mode:UILabel!
    @IBOutlet weak var holder3: UIView!
    @IBOutlet weak var holder2: UIView!
    @IBOutlet weak var holder1: UIView!
    @IBOutlet weak var instructionsTextView: UITextView!*/
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var band: UIView!
    @IBOutlet weak var stopsView: UIView!
    @IBOutlet weak var stops: UILabel!
    @IBOutlet weak var stopName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
