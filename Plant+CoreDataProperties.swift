//
//  Plant+CoreDataProperties.swift
//  FloralCode

//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Plant {

    @NSManaged var name: String?
    @NSManaged var date: Date?
    @NSManaged var lat: NSNumber?
    @NSManaged var lng: NSNumber?
    @NSManaged var temperature: NSNumber?
    @NSManaged var pressure: NSNumber?
    @NSManaged var altitude: NSNumber?
    @NSManaged var red: NSNumber?
    @NSManaged var green: NSNumber?
    @NSManaged var blue: NSNumber?
    @NSManaged var image: String?

}
