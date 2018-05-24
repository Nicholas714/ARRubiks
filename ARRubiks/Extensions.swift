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
    
    func direction(to:SCNVector3) -> (direction:MoveDirection?,distance:Float) {
        let xDistance = to.x - self.x
        let yDistance = to.y - self.y
        let zDistance = to.z - self.z
        if abs(xDistance) > abs(yDistance) && abs(xDistance) > abs(zDistance) {
//            print("沿x轴移动，方向为",xDistance)
            return (MoveDirection.xAxis,xDistance)
        }
        if abs(yDistance) > abs(xDistance) && abs(yDistance) > abs(zDistance) {
//            print("沿y轴移动，方向为",yDistance)
            return (MoveDirection.yAxis,yDistance)
        }
        if abs(zDistance) > abs(xDistance) && abs(zDistance) > abs(yDistance) {
//            print("沿z轴移动，方向为",zDistance)
            return (MoveDirection.zAxis,zDistance)
        }
        print("方向无法判断")
        return (nil,0)
    }
}

extension SCNVector4 {
    
    /// create a scnVector4 for rotation
    ///
    /// - Parameters:
    ///   - dirction: user move direction
    ///   - selectedSide: touch side
    ///   - degrees: move degrees in radian
    init(direction: MoveDirection, selectedSide: Side, degrees:Float) {
        self.init()
        switch direction {
        case .xAxis:
            switch selectedSide{
            //绕z轴旋转
            case .top: self.init(0, 0, 1, -degrees)
            case .bottom: self.init(0, 0, 1, degrees)
            //绕y轴旋转
            case .front: self.init(0, 1, 0, degrees)
            case .back: self.init(0, 1, 0, -degrees)
            case .left,.right: self.init()
            }
        case .yAxis:
            switch selectedSide{
            //绕x轴旋转
            case .front: self.init(1, 0, 0, -degrees)
            case .back: self.init(1, 0, 0, degrees)
            //绕z轴旋转
            case .right: self.init(0, 0, 1, degrees)
            case .left: self.init(0, 0, 1, -degrees)
            case .top,.bottom: self.init()
            }
        case .zAxis:
            switch selectedSide{
            //绕x轴旋转
            case .top: self.init(1, 0, 0, degrees)
            case .bottom: self.init(1, 0, 0, -degrees)
            //绕y轴旋转
            case .right: self.init(0, 1, 0, -degrees)
            case .left: self.init(0, 1, 0, degrees)
            case .front,.back: self.init()
            }
        }
    }
}

public extension Float {
    
    func isClose(to: Float) -> Bool {
        return abs(self - to) < 0.05
    }
    
    func offsetSwitchToRoundDegrees() -> Float {
        //对应的移动distanceFor90 距离，相当于旋转90度
        let distanceFor90:CGFloat = 0.2
        let remainder = abs(CGFloat(self) / distanceFor90).truncatingRemainder(dividingBy:(distanceFor90*4))
        let round = Int(remainder / distanceFor90 + 0.5)*90
        return Float(round) * Float(Double.pi / 180) * (self < 0 ? -1 : 1)
    }
    
    func offsetSwitchToDegrees() -> Float {
        //对应的移动distanceFor90 距离，相当于旋转90度
        let distanceFor90:CGFloat = 0.2
        return Float(CGFloat(self)/distanceFor90)*90*Float(Double.pi/180)
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
