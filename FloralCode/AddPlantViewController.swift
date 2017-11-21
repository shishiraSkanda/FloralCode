//
//  AddPlantViewController.swift
//  FloralCode
//
//

/*
 Importing MapKit to get user's current location as latitude and longitude values.
 Importing MobileCoreServices to implement camera and photos functionality.
 
 Implementing UIImagePickerControllerDelegate and UINavigationControllerDelegate for camera functions
 Implementing CLLocationManagerDelegate for location managers functions
 
 This controller is used to control the add plant view. Each plant must have a name and all the 
 attributes such as temperature, pressure, altitude, RGB values captured from the raspberry pi sensor 
 before it can be added. Additionally, an image may be chosen as well, and latitude and longitude values
 are captured if permission is given.
 */

import UIKit
import MobileCoreServices
import MapKit
import AssetsLibrary

protocol AddPlantDelegate
{
    func addPlant(_ plant: Plant1)
}
class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{
    
   // declaring the UI fields of the view
    
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNameText: UITextField!
    @IBOutlet weak var getDetailsButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    // declaring the global variables for the plant object
    let locationManager: CLLocationManager
    var delegate: AddPlantDelegate?
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

    // creating a view to display a progress spinner while data is being loaded from the server
    var progressView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        self.lat = nil
        self.lng = nil
        self.red = nil
        self.green = nil
        self.blue = nil
        self.temperature = nil
        self.pressure = nil
        self.altitude = nil
        self.imagePath = ""
        self.locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Implementing gesture recognition to allow the camera options to pop up when the image view is clicked
         Source: Stack Overflow
         Title: How to assign an action for UIImageView object in Swift
         Answered by: Aseider
         URL: http://stackoverflow.com/questions/27880607/how-to-assign-an-action-for-uiimageview-object-in-swift
         */
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action:#selector(AddPlantViewController.chooseImage))
        plantImage.isUserInteractionEnabled = true
        plantImage.addGestureRecognizer(tapGestureRecogniser)
        

    
        /*
         All Location Manager functions have been implemented based on the tutorials provided by Matthew Kairys.
         Credits: Tutorials by Matthew Kairys
        */
        // setting up location manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        // start recording the users location
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        print(" check : \(locationManager.location?.coordinate.latitude)")
        
        
        // setting up the progress view
        setProgressView()
        
    }
    
    
    // updates user's location periodically
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
         lat = locations[0].coordinate.latitude
         lng = locations[0].coordinate.longitude
        print("latitude \(lat!)")
        print("longitude \(lng!)")
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
            self.view.addSubview(self.progressView) // start showing the progress view
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
     This method is using the plant image view is clicked (using gesture control feature)
     If a camera is available then the camera mode is opened. If a camera does not exist on the
     device (for example, in the simulator) then the photo library or gallery is opened.
     Source: YouTube
     Tutorial: How to Take Photo with Camera in iOS | Swift Tutorial | Episode #56 LIVE
     Author: Dun Tran
     URL: https://www.youtube.com/watch?v=onwiChOkhyo
     */
    func chooseImage()
    {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.sourceType = .camera
        }
        else
        {
            imagePicker.sourceType = .photoLibrary
        }
        
        // if the user chooses to edit the chosen photo
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /*
     If the user chooses to cancel the capture of the image.
     Source: YouTube
     Tutorial: How to Take Photo with Camera in iOS | Swift Tutorial | Episode #56 LIVE
     Author: Dun Tran
     URL: https://www.youtube.com/watch?v=onwiChOkhyo
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("Choose image canceled")
    }
    
    /*
     Once the image is captured or chosen by the user, this function is called. There is a possibility
     that the user recorded or chose a video instead of an image. This is checked in this function.
     Only if the media picked is an image does the application assign the image to the plant.
     The realtive path of the image is saved.
     Source: YouTube
     Tutorial: How to Take Photo with Camera in iOS | Swift Tutorial | Episode #56 LIVE
     Author: Dun Tran
     URL: https://www.youtube.com/watch?v=onwiChOkhyo
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        print("In function \(mediaType)")
        if mediaType == (kUTTypeImage as String)
        {
            print(" In If \(mediaType)" )
            //self.plantImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            let imageUrl = info[UIImagePickerControllerReferenceURL] as! URL
            //            imagePath = imageUrl.path!
            print(imageUrl)
            
            let imageName = imageUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
            print("document directory: \(documentDirectory)")
            let localPath = documentDirectory + imageName
            let relativePath = imageUrl.relativePath
            
            imagePath = relativePath
            print("local path \(localPath)")
            print("relative path : \(relativePath)")
            
            
            let imageData = try? Data(contentsOf: imageUrl)
            //self.plantImage.image = UIImage(data: imageData!)
            let photoURL = URL(fileURLWithPath: localPath)
            
            
            let myImage: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
            
            let plantName = "\(self.plantNameText.text!).jpg"
            /*  let newImagePath = documentDirectory.stringByAppendingString(plantName)
             
             self.newImagePathForPlant = newImagePath
             print("new imagepath = \(self.newImagePathForPlant)")
             
             let newImageNSURL = NSURL(fileURLWithPath: newImagePath)
             print("new imageNSURL = \(newImageNSURL)")
             
             UIImageJPEGRepresentation(myImage, 1.0)?.writeToURL(newImageNSURL, atomically: true)
             
             self.plantImage.image = UIImage(data: NSData(contentsOfURL: newImageNSURL)!)
             
             
             print(imagePath)
             
             */
            let pathImage = fileInDocumentDirectory(plantName)
            
            //if let image = plantImage.image{
            if saveImage(myImage, path: pathImage)
            {
                self.plantImage.image = UIImage(contentsOfFile: pathImage)
                print("Shishira path : \(pathImage)")
                self.imagePath = pathImage
            }
            else{
                print("Error")
            }
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(_ image: UIImage, path : String) -> Bool
    {
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let result = (try? jpgImageData?.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        return result
        
    }
    
    
    func getDocumentUrl() -> URL
    {
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docUrl
    }
    func fileInDocumentDirectory(_ filename: String) -> String
    {
        let fileUrl = getDocumentUrl().appendingPathComponent(filename)
        return fileUrl.path
    }

    
    
    
    /*
     This method is invoked when the user clicks on the Save button on the navigation bar.
     The necessary attributes are read from the fields and global variables and a new Plant1
     object is created using there attributes. The new object is returned to the previous view controller 
     and added to the database.
     */
    @IBAction func saveAction(_ sender: AnyObject) {
       
        let newPlant: Plant1
        let plantName: String = plantNameText.text!
        let date: Date = Date()
        let r = red
        let g = green
        let b = blue
    
        if (plantName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0)
        {
            displayAlertMessage("Alert", message: "Plant name is mandatory")
        }
        else
        if (red == nil)     // if sensor data hasn't been captured
        {
            displayAlertMessage("Details not captured", message: "Please place the sensor on the object and capture the parameters")
        }
        else
        {
            if (lat != nil)     // if latitude and longitude has not been captured
            {
                newPlant = Plant1(name: plantName, lng: lng!, lat: lat!, temperature: temperature!, pressure: pressure!, altitude: altitude!, red: r!, green: g!, blue: b!, image: imagePath!, date: date)
            }
            else
            {
            
                newPlant = Plant1(name: plantName, temperature: temperature!, pressure: pressure!, altitude: altitude!, red: r!, green: g!, blue: b!, image: imagePath!, date: date)
            }
            delegate?.addPlant(newPlant)
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                self.stopProgressView()     // stop the progress spinner view if connection fails
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
     and altitude. Color tag has R, G, B information.
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

        self.colorView.backgroundColor = UIColor(red: CGFloat(red!/255), green: CGFloat(green!/255), blue: CGFloat(blue!/255), alpha: 1.0)
        
        stopProgressView()      // stop the progress spinner
        
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
        // setting the UI specifications
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
