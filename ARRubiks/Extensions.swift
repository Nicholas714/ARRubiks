//
//  Extensions.swift
//  ARRubiks
//
//  Created by Nicholas Grana on 6/10/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import UIKit
import SceneKit

extension UIColor {
    
    // rubiks colors as an array for easy iteration
    static let rubiksColors = [rubGreen, rubRed, rubBlue, rubOrange, rubWhite, rubYellow]
    
    // rubiks colors
    static let rubGreen = UIColor(red:0.00, green:0.61, blue:0.28, alpha:1.00)
    static let rubRed = UIColor(red:0.72, green:0.07, blue:0.20, alpha:1.00)
    static let rubBlue = UIColor(red:0.00, green:0.27, blue:0.68, alpha:1.00)
    static let rubOrange = UIColor(red:1.00, green:0.35, blue:0.00, alpha:1.00)
    static let rubWhite = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
    static let rubYellow = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.00)
    static let rubBlack = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    static let floor = UIColor(red:0.31, green:0.17, blue:0.08, alpha:1.00)
    
    // return random rubiks color (used for stars)
    static func randomRubiksColor() -> UIColor {
        return rubiksColors[Int(arc4random_uniform(UInt32(rubiksColors.count)))]
    }
    
}

extension SCNVector3 {
    
    // not exact distance (values are not sqaure rooted), just to find the closest distance to point
    func distance(to: SCNVector3) -> Double {
        let x = self.x - to.x
        let y = self.y - to.y
        let z = self.z - to.z
        
        return Double((x * x) + (y * y) + (z * z))
    }
    
}

public extension Float {
    
    func isClose(to: Float) -> Bool {
        return abs(self - to) < 0.05
    }
    
    // returns a random rotation in 90 degree intervals: 0, 90, 270, 360
    static func randomRotation() -> Float {
        // random between 1 and 359
        let randomDegreeNumber = Int(arc4random_uniform(360) + 1)
        // rounds it to nearest rotation
        let rotation = Float(Int((Double(randomDegreeNumber) / 90.0) + 0.5) * 90) * Float(Double.pi / 180)
        return rotation
    }
}

extension Double {
    
    // returns the smallest doule from a array
    func isSmallest(from: [Double]) -> Bool {
        for value in from {
            if self > value {
                return false
            }
        }
        return true
    }
    
}
