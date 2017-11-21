//
//  PlantViewController.swift
//  FloralCode
//
//

/*
 Importing MapKit to display location with an annotation on the map view.
 This class is used to control the display plant view. All the information relevant to
 the plant is displayed in this view. An Edit button is provided to allow the user to 
 edit the current plant being viewed.
 The editPlantDelegate is implemented to receive the updated plant object and display its features.
 */

import UIKit
import MapKit
import CoreData

class PlantViewController: UIViewController,editPlantDelegate {

    
    // declaring the UI elements
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var colorImage: UIImageView!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    
    // declaring global variables
    var currentPlant: Plant?
    var managedObjectContext: NSManagedObjectContext?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializing the UI fields with parameters of the current plant
        print(currentPlant?.name)
        self.plantNameLabel.text = currentPlant?.name
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
        
        // calling this function to add an annotation to the map view for the given location
        self.addLocationAnnotation()

        print("in plant view image url is :  \(currentPlant?.image)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editPlantDetails(_ sender: AnyObject) {
    }
    
    
    /*
     Puts an annotation on the map if the current category had a previous location assigned to it.
     Credits: Tutorials by Matthew Kairys
     */
    func addLocationAnnotation()
    {
        if (currentPlant?.lat != nil)     // if it has a previous latitude
        {
            let loc = CLLocationCoordinate2D(latitude: Double((currentPlant?.lat)!) , longitude: Double((currentPlant?.lng)!))
            
            print("lat: \(Double((currentPlant?.lat)!))   lng: \(Double((currentPlant?.lng)!))")
            
            let region = (name: currentPlant?.name, coordinate:loc)
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = region.coordinate
            mapAnnotation.title = region.name
            locationMapView.addAnnotation(mapAnnotation)
            
            // zooming into the area near the annotation
            let area = MKCoordinateRegion(center: loc , span: MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01))
            locationMapView.setRegion(area, animated: true)
        }
    }
    
    // implementing the editPlantDelegate method and updating the current object with the updated one
    func editPlant(_ updatedPlant: Plant) {
        self.currentPlant = updatedPlant
        self.viewDidLoad()
    }
        
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditPlantSegue")
        {
            let controller: PlantEditViewController = segue.destination as! PlantEditViewController
            controller.currentPlant = self.currentPlant
            controller.managedObjectContext = self.managedObjectContext
            controller.delegate = self
        }
        
    }
    

}
