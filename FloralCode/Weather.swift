//
//  Weather.swift
//  FloralCode
//

/*
 This class is used to model a Weather object which would have attributes such as
 temperature, pressure and altitude. Each of them is of type Double.
 */

import UIKit

class Weather: NSObject {
    
    // weather attributes
    var temperature: Double?
    var pressure: Double?
    var altitude: Double?

    // default constructor
    override init() {
        self.temperature = nil
        self.pressure = nil
        self.altitude = nil
    }
    
    // parameterized constructor
    init(temperature: Double, pressure: Double, altitude: Double) {
        self.temperature = temperature
        self.pressure = pressure
        self.altitude = altitude
    }
}
