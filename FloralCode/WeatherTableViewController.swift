//
//  WeatherTableViewController.swift
//  FloralCode
//

/*
 This class is used to display past values 'N' of weather in a table view. One cell is provided to accept 
 input from the user. This value or 'N' is any integer from 1 to 50. the second static cell is used to 
 provide header for the table columns. 
 The last N weather values are downloaded from sensors connected to a raspberry pi using an HTTP request.
 A refresh button on the navigation bar is provided to allow the user to update table view if the 'N' value
 is changed.
 */
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class WeatherTableViewController: UITableViewController {

    // declaring global variables
    var weatherList: NSMutableArray?
    var N: String?
    var requestedN: Int?
    
    // defining a progress view
    var progressView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        self.weatherList = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setting up the progress view
        setProgressView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // declaring 3 section - 2 static and one dynamic.
        // first section to accept input, next section acts as header and third section hold the dynamic values for weather
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // a single row for the static sections; dynamic sections depends on the number of records in the
        // list of weather objects
        switch section
        {
        case 0: return 1
        case 1: return 1
        case 2: return (weatherList?.count)!
        default: return 1
        }
    }

    @IBAction func stepperValueChanged(_ sender: AnyObject) {
    }
    
    
    // assigning the fields of the cells with values from the list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 2)
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell

        let weather = self.weatherList![indexPath.row] as! Weather
            cell.temperatureLabel.text = "\(String(format: "%.0f", round(weather.temperature!)))°"
        cell.pressureLabel.text = String(format: "%.2f", weather.pressure!)
        cell.altitudeLabel.text = String(format: "%.2f", weather.altitude!)
        
        return cell
        }
        else
        if (indexPath.section == 0)  // if input cell then set label
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataInputCell", for: indexPath) as! DataInputCell
             print("cell value is on load \(cell.numberLabel.text!)")
            return cell
        }
        else        // if header cell
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            return cell
        }
    }
    

    /*
     Invoked when the user chooses to refresh the number of records required from the server.
     If internet connection is okay, the new data is downloaded. Else an alert is displayed.
    */
    @IBAction func refreshValues(_ sender: AnyObject) {
        // checking if network is available (Reachability class is defined in another file)
        
        if Reachability.isConnectedToNetwork() == true      // if data network exists then download the JSON article
        {
            print("Internet connection OK")
            downloadSensorData()
            self.view.addSubview(self.progressView)
        }
        else        // if data network isn't available show an alert
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }

    /*
     If internet connection exists, this method is invoked when the view loads as well as when the user clicks the refresh button on the navigation bar. Sensor data from the server is downloaded by making an HTTP request to the server
     that is deployed on the raspberry pi. Should the IP address of the serve change, the IP address
     would have to be updated in the below URL as well.
     Once the JSON data is downloaded, the parsing method is called to extract information from the
     JSON data.
     An alert is displayed if a connection could not be made to the server.
     */
    func downloadSensorData() {
        
        self.weatherList?.removeAllObjects()
        
        // N value in the URL refers to the number of records to be downloaded from the server
        var url: URL
        N = DataInputCell.Static.stepperValue
        self.requestedN = Int(N!)
        var updateURL: String
        updateURL = "http://118.139.61.48:8080/floralcode/sensordata?N=\(N!)"
        print(updateURL)
        url = URL(string: updateURL)!
        
        //print(url)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage("Connection Failed", message: "Failed to retrieve data from the server")
            }
            else
            {
                self.parseJSON(data!)
                
            }
            //self.syncCompleted = true
        })
        task.resume()
    }
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data. The Weather tag has information regarding temperature, pressure
     and altitude.
     The attributes are used to create a new weather object that is added to the list.s
     */
    func parseJSON(_ colourJSON:Data){
        do{
            
            let result = try JSONSerialization.jsonObject(with: colourJSON, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            print("Result : \(result)")
            
            let errorData = result["Error"] as! NSDictionary
            let code = errorData.object(forKey: "code") as! String
            
            if(code == "null")
            {
            
            if let item = result["SensorData"] as? NSArray
            {
                print("sensor data : \(item)")
                for data in item
                {
                    if let weatherData = data["Weather"] as? NSDictionary
                    {
                        var temperature = weatherData.object(forKey: "temperature")! as! Double
                        let pressure = weatherData.object(forKey: "pressure")! as! Double
                        let altitude = weatherData.object(forKey: "altitude")! as! Double
                            
                        print("Temp: \(temperature)   Pres: \(pressure)  Alti: \(altitude)")
                        let currentWeather = Weather(temperature: temperature, pressure: pressure, altitude: altitude)
                        self.weatherList?.add(currentWeather)
                        
                    }
                }
            }
            }
            else
            {
                self.displayAlertMessage("Sensor Failure", message: "Server is unable to detect sensor")
                
            }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopProgressView()
                    if(self.weatherList?.count < self.requestedN)
                    {
                        self.displayAlertMessage("Limited Data", message: "The server currently has only \((self.weatherList?.count)!) records of sensor data.")
                    }
                }
        }
        catch{
                print("JSON Serialization error")
            }
        }
    
    
    /*
     A function to allow custom alerts to be created by passing a title and a message
     */
    func displayAlertMessage(_ title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
        self.stopProgressView()
    }

    
    /*
     Setting up the progress view that displays a spinner while the serer data is being downloaded.
     The view uses an activity indicator (a spinner) and a simple text to convey the information.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func setProgressView()
    {
        self.progressView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        self.progressView.backgroundColor = UIColor.lightGray
        self.progressView.layer.cornerRadius = 10
        let wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        wait.color = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        wait.hidesWhenStopped = false
        wait.startAnimating()
        
        let message = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        message.text = "Retrieving data..."
        message.textColor = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        
        self.progressView.addSubview(wait)
        self.progressView.addSubview(message)
        self.progressView.center = self.view.center
        self.progressView.tag = 1000
        
    }

    /*
     This method is invoked to remove the progress spinner from the view.
     Source: YouTube
     Tutorial: Swift - How to Create Loading Bar (Spinners)
     Author: Melih Şimşek
     URL: https://www.youtube.com/watch?v=iPTuhyU5HkI
     */
    func stopProgressView()
    {
        let subviews = self.view.subviews
        for subview in subviews
        {
            if subview.tag == 1000
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
