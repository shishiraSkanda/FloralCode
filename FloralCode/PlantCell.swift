//
//  PlantCell.swift
//  FloralCode
//
//

/*
 This class is used to model a single cell of the table view that holds a number of plant objects.
  Each cell is designed to have an image and a name label against it.
*/
import UIKit

class PlantCell: UITableViewCell {

    // declaring the cell attributes
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
