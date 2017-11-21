//
//  Plant.swift
//  FloralCode
//
//

/*
 This class defines a Plant object which has attributes such as name of the plant, latitude
 and longitude of the location where it was found, the weather conditions in which it was
 captured such as temperature, pressure and altitude, RGB values of the colour of the plant,
 an image of the plant and the date of creating the record.
 */

import UIKit

class Plant1: NSObject {
    
    // declaring the plant attributes
    var name: String?
    var lng: Double?
    var lat: Double?
    var temperature: Double?
    var pressure: Double?
    var altitude: Double?
    var red: Double?
    var green: Double?
    var blue: Double?
    var image: String?
    var date: Date?
    
    override init() {
        self.name = nil
        self.lng = nil
        self.lat = nil
        self.temperature = nil
        self.pressure = nil
        self.altitude = nil
        self.red = nil
        self.green = nil
        self.blue = nil
        self.image = nil
        self.date = nil
        
    }
    
    // parameterized constructor with all parameters
    init(name: String,lng:Double,lat: Double,temperature: Double,pressure: Double,altitude: Double,red: Double,green:Double,blue: Double, image:String, date: Date)
    {
        self.name = name
        self.lng = lng
        self.lat = lat
        self.temperature = temperature
        self.pressure = pressure
        self.altitude = altitude
        self.red = red
        self.green = green
        self.blue = blue
        self.image = image
        self.date = date
    }
    
    // parameterized constructor with optional location (lat and lng)
    init(name: String, temperature: Double,pressure: Double,altitude: Double,red: Double,green:Double,blue: Double, image:String, date: Date)
    {
        self.name = name
        self.lat = nil
        self.lng = nil
        self.temperature = temperature
        self.pressure = pressure
        self.altitude = altitude
        self.red = red
        self.green = green
        self.blue = blue
        self.image = image
        self.date = date
    }
}
