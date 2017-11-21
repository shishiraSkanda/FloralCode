//
//  PlantEditViewController.swift
//  FloralCode
//
//

/*
 Importing MapKit to get user's current location as latitude and longitude values.
 Importing CoreData to update the database with new values of existing object
 
 Implementing CLLocationManagerDelegate for location managers functions
 
 This controller is used to control the edit plant view. Each plant must have a name and all the
 attributes such as temperature, pressure, altitude, RGB values captured from the raspberry pi sensor
 before it can be added. Additionally, an image may be chosen as well, and latitude and longitude values
 are captured if permission is given.
 By default, the existing values are populated. Any changes made are updated.
 */

import UIKit
import CoreData
import MapKit

/*
 Sends back the updated plant values to the previous view controller.
 */
protocol  editPlantDelegate {
    func editPlant(_ updatedPlant: Plant)
}

class PlantEditViewController: UIViewController, CLLocationManagerDelegate {
    
    
    // declaring the UI elements
    @IBOutlet weak var plantName: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var colorImage: UIImageView!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    
    // creating a view to display a progress spinner while data is being loaded from the server
    var progressView = UIView()
    
    // declaring the global variables for the plant object
    let locationManager: CLLocationManager
    var name: String?
    var lat: Double?
    var lng: Double?
    var red: Double?
    var green: Double?
    var blue: Double?
    var temperature: Double?
    var pressure: Double?
    var altitude: Double?
    var imagePath: String!
    var imagePicker: UIImagePickerController!
    var currentPlant: Plant?
    var delegate:editPlantDelegate?
    var managedObjectContext: NSManagedObjectContext?
    var newDate: Date?
    
    required init?(coder aDecoder: NSCoder) {
        self.locationManager = CLLocationManager()
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populating the fields with the current values
        print(currentPlant?.name)
        self.plantName.text = currentPlant?.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.dateLabel.text = dateFormatter.string(from: (currentPlant?.date)! as Date)
        self.temperatureLabel.text = "\(String(format: "%.0f", round(Double((currentPlant?.temperature)!))))°"
        self.pressureLabel.text = "\(String(format: "%.2f", Double((currentPlant?.pressure)!))) kPa"
        self.altitudeLabel.text = "\(String(format: "%.2f", Double((currentPlant?.altitude)!))) meters"
        self.redLabel.text = String(format: "%.0f", round(Double((currentPlant?.red)!)))
        self.greenLabel.text = String(format: "%.0f", round(Double((currentPlant?.green)!)))
        self.blueLabel.text = String(format: "%.0f", round(Double((currentPlant?.blue)!)))
        print(currentPlant?.lat)
        self.colorImage.backgroundColor = UIColor(red: CGFloat(Double((currentPlant?.red)!)/255), green: CGFloat(Double((currentPlant?.green)!)/255), blue: CGFloat(Double((currentPlant?.blue)!)/255), alpha: 1.0)
        
        
        // populating the global variables with the current values
        self.name = currentPlant?.name
        self.newDate = currentPlant?.date as Date?
        if (currentPlant?.lat != nil)
        {
            self.lat = Double((currentPlant?.lat)!)
            self.lng = Double((currentPlant?.lng)!)
        }
        else
        {
            self.lat = nil
            self.lng = nil
        }
        self.temperature = Double((currentPlant?.temperature)!)
        self.pressure = Double((currentPlant?.pressure)!)
        self.altitude = Double((currentPlant?.altitude)!)
        self.red = Double((currentPlant?.red)!)
        self.green = Double((currentPlant?.green)!)
        self.blue = Double((currentPlant?.blue)!)
        self.imagePath = currentPlant?.image
        
        
        // this function is called to put an annotation to the map view if a location is assigned
        self.addLocationAnnotation()

        // setting up the progress view
        setProgressView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     This method is invoked when the user clicks the Get Details button to read the sensor values from the
     node.js server deployed on the raspberry pi. If internet connection is okay, the data is downloaded.
     */
    @IBAction func getPlantDetails(_ sender: AnyObject) {
        
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
     This method is invoked when the user clicks on the Save button on the navigation bar.
     The necessary attributes are read from the fields and global variables and the current object is updated 
     with the new values. The values are updated in the core data as well.
     */
    @IBAction func saveUpdatedPlant(_ sender: AnyObject)
    {
        self.name = self.plantName.text!
        // let latitude = lat
        // let longitude = lng
        if(self.name!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0)
        {
            displayAlertMessage("Alert", message: "Plant name is mandatory")
        }
        else
            if (red == nil)
            {
                displayAlertMessage("Details not captured", message: "Please place sensor on the object and capture the parameters")
            }
            else
            {
                
                self.currentPlant?.name = self.name;
                self.currentPlant?.date = self.newDate
                self.currentPlant?.temperature = self.temperature as NSNumber?
                self.currentPlant?.pressure = self.pressure as NSNumber?
                self.currentPlant?.altitude = self.altitude as NSNumber?
                self.currentPlant?.red = self.red as NSNumber?
                self.currentPlant?.green = self.green as NSNumber?
                self.currentPlant?.blue = self.blue as NSNumber?
                self.currentPlant?.lat = self.lat as NSNumber?
                self.currentPlant?.lng = self.lng as NSNumber?
                self.currentPlant?.image = self.imagePath
                do
                {
                    try self.managedObjectContext!.save()
                }
                catch let error
                {
                    print("Could not save Deletion \(error)")
                }
                
                
                delegate?.editPlant(self.currentPlant!)
                self.navigationController?.popViewController(animated: true)
        }

    }
    
    // invoked if the user chooses to update date
    @IBAction func resetDate(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.newDate = Date()
        self.dateLabel.text = dateFormatter.string(from: self.newDate!)
        
    }
    
    
    /*
     All Location Manager functions have been implemented based on the tutorials provided by Matthew Kairys.
     Credits: Tutorials by Matthew Kairys
     */
    // this function is invoked if the user chooses to update location information
    @IBAction func updateLocation(_ sender: AnyObject) {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.addLocationAnnotation()
        }
    }
    
     // updates user's location periodically
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lat = locations[0].coordinate.latitude
        lng = locations[0].coordinate.longitude
        print("latitude \(lat!)")
        print("longitude \(lng!)")
        
        /* if let location = locations.first
         {
         let currentLocation: CLLocationCoordinate2D = (manager.location?.coordinate)!
         lat = currentLocation.latitude
         lng = currentLocation.longitude
         print("latitude = \(lat)")
         print("longitude = \(lng)")
         }*/
    }
    
      /*
     If internet connection exists, this method is invoked when the user clicks the Get Details button
     on the view. Sensor data from the server is downloaded by making an HTTP request to the server
     that is deployed on the raspberry pi. Should the IP address of the serve change, the IP address
     would have to be updated in the below URL as well.
     Once the JSON data is downloaded, the parsing method is called to extract information from the
     JSON data.
     An alert is displayed if a connection could not be made to the server.
     */
    func downloadSensorData() {
        
        var url: URL
        // N value in the URL refers to the number of records to be downloaded from the server. Since we require only one (the latest) record, we have given N = 1
        url = URL(string: "http://118.139.61.48:8080/floralcode/sensordata?N=1")!
        
        //print(url)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if (error != nil)
            {
                print("Error \(error)")
                self.displayAlertMessage("Connection Failed", message: "Failed to retrieve data from the server")
                self.stopProgressView()
            }
            else
            {
                self.parseRGBJSON(data!)
                
            }
            //self.syncCompleted = true
        })
        task.resume()
    }
    
    
    /*
     This function is invoked after the JSON data is downloaded from the server. The key-value method is used
     to extract all the necessary data. The Weather tag has information regarding temperature, pressure
     and altitude.
     */
    func parseRGBJSON(_ colourJSON:Data){
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
                            temperature = weatherData.object(forKey: "temperature")! as! Double
                            pressure = weatherData.object(forKey: "pressure")! as! Double
                            altitude = weatherData.object(forKey: "altitude")! as! Double
                            print("Temp: \(temperature!)   Pres: \(pressure!)  Alti: \(altitude!)")
                            
                        }
                        if let colorData = data["Color"] as? NSDictionary
                        {
                            red = colorData.object(forKey: "Red")! as! Double
                            green = colorData.object(forKey: "Green")! as! Double
                            blue = colorData.object(forKey: "Blue")! as! Double
                            print("R: \(red!)   G: \(green!)  B: \(blue!)")
                        }
                    }
                }
            }
            else
            {
                self.displayAlertMessage("Sensor Failure", message: "Server is unable to detect sensor")
                
            }
            
            DispatchQueue.main.async {
                if(self.temperature != nil && self.red != nil)
                {
                    self.assignLabels()
                }
                
                
            }
        }
        catch{
            print("JSON Serialization error")
        }
    }
    
    /*
     This method is used to populate specific labels in the view with data that is downloaded from
     the server.
     */

    func assignLabels()
    {
        print("Round value : \(round(red!))")
        self.redLabel.text = String(format: "%.0f",round(red!))
        self.greenLabel.text = String(format: "%.0f",round(green!))
        self.blueLabel.text = String(format: "%.0f",round(blue!))
        self.temperatureLabel.text = "\(String(format: "%.0f", round(self.temperature!))) °C"
        self.pressureLabel.text = "\(String(format: "%.2f", self.pressure!)) kPa"
        self.altitudeLabel.text = "\(String(format: "%.2f", self.altitude!)) meters"
        
        self.colorImage.backgroundColor = UIColor(red: CGFloat(red!/255), green: CGFloat(green!/255), blue: CGFloat(blue!/255), alpha: 1.0)
        self.stopProgressView()
        
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
     Puts an annotation on the map if the current category had a previous location assigned to it
     */
    func addLocationAnnotation()
    {
        let allAnnotations = self.locationMapView.annotations
        self.locationMapView.removeAnnotations(allAnnotations)
        
        if (self.lat != nil)     // if it has a previous latitude
        {
            let loc = CLLocationCoordinate2D(latitude: Double((self.lat)!) , longitude: Double((self.lng)!))
            
            print("lat: \(Double((self.lat)!))   lng: \(Double((self.lng)!))")
            
            let region = (name: self.name, coordinate:loc)
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = region.coordinate
            mapAnnotation.title = region.name
            locationMapView.addAnnotation(mapAnnotation)
            
            let area = MKCoordinateRegion(center: loc , span: MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01))
            locationMapView.setRegion(area, animated: true)
        }
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


}
