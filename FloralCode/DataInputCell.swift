//
//  DataInputCell.swift
//  FloralCode


/*
 Models a cell in the weather table view which takes an input for the number of past records
 to retrieve from the server. A stepper and a number label is used for this.
 */
import UIKit

class DataInputCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberStepper: UIStepper!
    
    
    // to allow access to this stepper value in another class
    struct Static
    {
        static var stepperValue = String()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // setting up parameters of the stepper; we assume a maximum of 50 records to be retrieved.
        self.numberStepper.maximumValue = 50
        self.numberStepper.minimumValue = 0
        self.numberStepper.stepValue = 1
        self.numberStepper.wraps = true
        self.numberStepper.autorepeat = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // invoked when the stepper value is changed by the user. This updates the label view with current value.
    @IBAction func stepperValueChange(_ sender: AnyObject) {
        numberLabel.text = String(Int(numberStepper.value))
        print(numberLabel.text)
        DataInputCell.Static.stepperValue = (numberLabel.text)!
        
    }

}
