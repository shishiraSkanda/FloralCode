//
//  PlantTableViewController.swift
//  FloralCode
//
//

import UIKit
import CoreData
import MapKit

/*
 Used to control the view with a list of plants that have been recorded. The controller provides
 a button to add a new plant and the table view can be clicked to view more details about the plant.
 A plant object may be removed from the list by swiping left and clicking on the Delete button.
 */

class PlantTableViewController: UITableViewController, UIImagePickerControllerDelegate, AddPlantDelegate {
    
    // declaring the global variables
    var plantList: NSMutableArray
    var managedObjectContext: NSManagedObjectContext
    var selectedIndex: Int?
        
    required init?(coder aDecoder: NSCoder) {

        self.plantList = NSMutableArray()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetching all the objects from Core Data "Plant" table into the plantList array
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Plant", in:
            self.managedObjectContext)
        fetchRequest.entity = entityDescription
        var result = []
        do
        {
            result = try self.managedObjectContext.fetch(fetchRequest)
            self.plantList.addObjects(from: result as Array)
        }
            
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
        
       // print((self.plantList.lastObject as! Plant).image!);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // only one section to display the objects
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows is equal to number of objects in the list
        return plantList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantCell
        
        // Configure the cell
        let c: Plant = self.plantList[indexPath.row] as! Plant
        cell.plantName.text = c.name
        
        if (c.image != nil)
        {
            print("Image path is \(c.image!)")
            if FileManager.default.fileExists(atPath: c.image!) {
    
                cell.plantImage.image = UIImage(contentsOfFile: c.image!)
            }
            else
            {
                cell.plantImage.backgroundColor = UIColor(red: CGFloat(Double(c.red!)/255), green: CGFloat(Double(c.green!)/255), blue: CGFloat(Double(c.blue!)/255), alpha: 1.0)
            }
        }
        else
        {
            cell.plantImage.backgroundColor = UIColor(red: CGFloat(Double(c.red!)/255), green: CGFloat(Double(c.green!)/255), blue: CGFloat(Double(c.blue!)/255), alpha: 1.0)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddPlantSegue")
        {
            let destinationVC: AddPlantViewController = segue.destination as! AddPlantViewController
            destinationVC.delegate = self
        }
        if(segue.identifier == "ViewPlantSegue")
        {
            let destinationVC: PlantViewController = segue.destination as! PlantViewController
            self.selectedIndex = self.tableView.indexPathForSelectedRow!.row
            destinationVC.currentPlant = self.plantList.object(at: self.selectedIndex!) as! Plant
            destinationVC.managedObjectContext = self.managedObjectContext
            //destinationVC.delegate = self
            
        }
    }
    
    /* 
     implementing the AddPlantDelegate method. The new plant object returned from the previous view
     A new entity object is created using the attributes of the new plant object that is returned.
     The updateTable() method is called to add this new entity to the Core Data table.
     The table is reloaded with the new data.
    */
    func addPlant(_ plant: Plant1) {
        
        let newPlant: Plant = (NSEntityDescription.insertNewObject(forEntityName: "Plant",
            into: self.managedObjectContext) as? Plant)!
        newPlant.name = plant.name
        newPlant.image = plant.image
        newPlant.lat = plant.lat as NSNumber?
        newPlant.lng = plant.lng as NSNumber?
        newPlant.temperature = plant.temperature as NSNumber?
        newPlant.pressure = plant.pressure as NSNumber?
        newPlant.altitude = plant.altitude as NSNumber?
        newPlant.red = plant.red as NSNumber?
        newPlant.green = plant.green as NSNumber?
        newPlant.blue = plant.blue as NSNumber?
        newPlant.date = plant.date
        updateTable()
        self.tableView.reloadData()
    }
    
    
    // reloads the table by deleting old information and reading new one from Core Data
    func updateTable()
    {
        do
        {
            try self.managedObjectContext.save()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entityDescription = NSEntityDescription.entity(forEntityName: "Plant", in:
                self.managedObjectContext)
            fetchRequest.entity = entityDescription
            var result = []
            do
            {
                self.plantList.removeAllObjects()
                result = try self.managedObjectContext.fetch(fetchRequest)
                self.plantList.addObjects(from: result as Array)
            }
                
            catch
            {
                let fetchError = error as NSError
                print(fetchError)
            }
            
        }
        catch let error
        {
            print("Could not add to table \(error)")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            // Delete the row from the data source
            managedObjectContext.delete(plantList.object(at: indexPath.row) as! NSManagedObject)
            self.plantList.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //Save the ManagedObjectContext
            do
            {
                try self.managedObjectContext.save()
            }
            catch let error
            {
                print("Could not save Deletion \(error)")
            }
        }
    }
}
