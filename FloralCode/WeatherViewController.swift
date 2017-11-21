//
//  WeatherViewController.swift
//  FloralCode
//

/*
 Importing MapKit to get current location of the user
 Implementing CLLocationManagerDelegate for Location Manager functions
 
 This class controls the weather view which displays weather data from two sources - 
 the sensors connected to the raspberry pi and an open source weather API.
 A refresh button on the navigation bar is provided to allow the user to update the weather location to get
 the current value from both sources.
 A History button is provided on the navigation bar to direct the user to a table view that allows the user
 to view history or past 'N' weather values where N is any integer from 1 to 50.
 */
import UIKit
import CoreData
import MapKit

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    var managedObjectContext: NSManagedObjectContext
    
    // setting up UI elements
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var APITemperatureLabel: UILabel!
    
    @IBOutlet weak var APIDescriptionLabel: UILabel!
    
    @IBOutlet weak var APIMinTempLabel: UILabel!
    
    @IBOutlet weak var APIMaxTempLabel: UILabel!
    
    @IBOutlet weak var APIPressureLabel: UILabel!
    
    @IBOutlet weak var APIHumidityLabel: UILabel!
    
    @IBOutlet weak var APIWindLabel: UILabel!
    
    @IBOutlet weak var sensorWeatherImageView: UIImageView!
    
    
    // declaring global variables
    var temperature: Double?
    var pressure: Double?
    var altitude: Double?
    var lat: Double?
    var lng: Double?
    let locationManager: CLLocationManager
    
    // for the weather API
    var descriptionAPI: String?
    var iconAPI: String?
    var temperatureAPI: Double?
    var maxTemperatureAPI: Double?
    var minTemperatureAPI: Double?
    var pressureAPI: Double?
    var windSpeedAPI: Double?
    var humidityAPI: Double?
    
    // setting up the progress view
    var progressView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        
        // initializing to default values
        self.temperature = nil
        self.pressure = nil
        self.altitude = nil
        self.lat = -37.5
        self.lng = 144.0
        self.temperatureAPI = nil
        self.maxTemperatureAPI = nil
        self.minTemperatureAPI = nil
        self.pressureAPI = nil
        self.humidityAPI = nil
        self.windSpeedAPI = nil
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        self.locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // checking if network is available (Reachability class is defined in another file)
        
        if Reachability.isConnectedToNetwork() == true      // if data network exists then download the JSON article
        {
            print("Internet connection OK")
            downloadSensorData()
            downloadWeatherAPIData()
        }
        else        // if data network isn't available show an alert
        {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }

        self.sensorWeatherImageView.layer.cornerRadius = 15.0
        
        /*
         All Location Manager functions have been implemented based on the tutorials provided by Matthew Kairys.
         Credits: Tutorials by Matthew Kairys
         */
        // setting up location manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        // setting up the progress view
        setProgressView()
        self.view.addSubview(self.progressView)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Invoked when the user clicks the refresh button
    @IBAction func refreshWeather(_ sender: AnyObject) {
        self.viewDidLoad()
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
                        self.temperature = weatherData.object(forKey: "temperature")! as! Double
                        self.pressure = weatherData.object(forKey: "pressure")! as! Double
                        self.altitude = weatherData.object(forKey: "altitude")! as! Double
                        print("Temp: \(self.temperature!)   Pres: \(self.pressure!)  Alti: \(self.altitude!)")
   
                    }
                    // checking for error
                    
                }
            }
            }
            else
            {
                self.displayAlertMessage("Sensor Failure", message: "Server is unable to detect sensor")
                
            }
            
            DispatchQueue.main.async {
                if(self.temperature != nil)
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
        self.temperatureLabel.text = "\(String(format: "%.0f", self.temperature!)) °C"
        self.pressureLabel.text = "\(String(format: "%.2f", self.pressure!)) kPa"
        self.altitudeLabel.text = "\(String(format: "%.2f", self.altitude!)) meters"
        self.stopProgressView()
    }
    
    /*
     This method is used to read weather data from an open source weather API called OpenWeatherMap.
     The downloaded JSON data is parsed to get additional weather information, apart from what we get from
     the raspberry pi server.
     Source: OpenWeatherMap
     URL: http://openweathermap.org
    */
    
    func downloadWeatherAPIData() {
        
        
        var url: URL
        let weatherURL = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat!)&lon=\(lng!)&APPID=7b74a771a13683ad3695bfd9e591c2f3"
        print(weatherURL)
        url = URL(string: weatherURL)!
        
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
                self.parseWeatherAPIJSON(data!)
                
            }
            //self.syncCompleted = true
        })
        task.resume()
    }
    
    /*
     The downloaded JSON data is parsed using key-value method.
     We extract data such as min and max temperature, current temperature, pressue,
     humidity and wind speed.
     An icon path is also taken from this data and is used to download an image from a specific
     URL (as shown in downloadIconData() method defined later)
    */
    func parseWeatherAPIJSON(_ weatherJSON:Data){
        do{
            
            let result = try JSONSerialization.jsonObject(with: weatherJSON, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            print("Result : \(result)")
            
            
            if let item = result["weather"] as? NSArray
            {
                print("weather data : \(item)")
                for data in item
                {
                    let weatherData = data as! NSDictionary
                    self.descriptionAPI = weatherData.object(forKey: "description") as! String
                    self.iconAPI = weatherData.object(forKey: "icon") as! String
                    print("description \(descriptionAPI) and icon \(iconAPI)")
                }
            }
            if let item = result["main"] as? NSDictionary
            {
                self.temperatureAPI = item.object(forKey: "temp") as! Double
                self.pressureAPI = item.object(forKey: "pressure") as! Double
                self.humidityAPI = item.object(forKey: "humidity") as! Double
                self.maxTemperatureAPI = item.object(forKey: "temp_max") as! Double
                self.minTemperatureAPI = item.object(forKey: "temp_min") as! Double
                print("temperature \(self.temperatureAPI) pressure \(self.pressureAPI) humidity \(self.humidityAPI) max temp \(self.maxTemperatureAPI) min temp \(self.minTemperatureAPI) ")
            }
            if let item = result["wind"] as? NSDictionary
            {
                self.windSpeedAPI = item.object(forKey: "speed") as! Double
                print("wind speed \(self.windSpeedAPI) ")
            }
            DispatchQueue.main.async {
                if (self.temperatureAPI != nil)
                {
                    self.assignWeatherLabels()
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
    func assignWeatherLabels()
    {
        downloadIconData()
        self.APITemperatureLabel.text = "\(String(format: "%.0f",round(temperatureAPI! - 273.15)))°"
        self.APIDescriptionLabel.text = "\(self.descriptionAPI!)"
        self.APIMinTempLabel.text = "\(String(format: "%.0f",round(minTemperatureAPI! - 273.15)))°"
        self.APIMaxTempLabel.text = "\(String(format: "%.0f",round(maxTemperatureAPI! - 273.15)))°"
        self.APIPressureLabel.text = "\(String(format: "%.0f", round(self.pressureAPI!))) hPa"
        self.APIHumidityLabel.text = "\(String(format: "%.0f", round(self.humidityAPI!)))%"
        self.APIWindLabel.text = "\(String(format: "%.0f", (self.windSpeedAPI!) * (18/5))) km/hr"
    }

    
    /*
     This method is used to download a weather icon from a given url.
    */
    func downloadIconData() {
        var url: URL
        let imageURL = "http://openweathermap.org/img/w/\(self.iconAPI!).png"
        print(imageURL)
        url = URL(string: imageURL)!
        
        let data = try? Data(contentsOf: url)
        self.weatherIcon.image = UIImage(data:data!)
        
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
     All Location Manager functions have been implemented based on the tutorials provided by Matthew Kairys.
     Credits: Tutorials by Matthew Kairys
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lat = locations[0].coordinate.latitude
        lng = locations[0].coordinate.longitude
        print("latitude \(lat!)")
        print("longitude \(lng!)")
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
