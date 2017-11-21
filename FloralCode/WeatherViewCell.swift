//
//  WeatherViewCell.swift
//  FloralCode
//

/*
 This class is used to model a weather cell in a table view controller which displays the past values of
 weather in a table view.
 Each cell is designed to contain pressure, temperature and altitude values.
 */
import UIKit

class WeatherCell: UITableViewCell {

    // declaring the attributes of weather cell
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var altitudeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
