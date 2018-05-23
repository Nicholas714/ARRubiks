//
//  ARCubeNode.swift
//  ARRubiks
//
//  Created by Nicholas Grana on 6/10/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import ARKit

class ARCubeNode: SCNNode {
    
    var animating = false
    var offset: CGFloat = 0
    
    override init() {
        super.init()
        
        // makes colored 27 SCNBox that makes up the cube
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let box = SCNBox(width: 0.9, height: 0.9, length: 0.9, chamferRadius: 0.0)
                    
                    let greenMaterial = SCNMaterial()
                    greenMaterial.diffuse.contents = UIColor.rubBlack
                    if z + 1 > 1 {
                        greenMaterial.diffuse.contents = UIColor.rubGreen
                    }
                    
                    let redMaterial = SCNMaterial()
                    redMaterial.diffuse.contents = UIColor.rubBlack
                    if x + 1 > 1 {
                        redMaterial.diffuse.contents = UIColor.rubRed
                    }
                    
                    let blueMaterial = SCNMaterial()
                    blueMaterial.diffuse.contents = UIColor.rubBlack
                    if z - 1 < -1 {
                        blueMaterial.diffuse.contents = UIColor.rubBlue
                    }
                    
                    let orangeMaterial = SCNMaterial()
                    orangeMaterial.diffuse.contents = UIColor.rubBlack
                    if x - 1 < -1 {
                        orangeMaterial.diffuse.contents = UIColor.rubOrange
                    }
                    
                    let whiteMaterial = SCNMaterial()
                    whiteMaterial.diffuse.contents = UIColor.rubBlack
                    if y + 1 > 1 {
                        whiteMaterial.diffuse.contents = UIColor.rubWhite
                    }
                    
                    let yellowMaterial = SCNMaterial()
                    yellowMaterial.diffuse.contents = UIColor.rubBlack
                    if y - 1 < -1 {
                        yellowMaterial.diffuse.contents = UIColor.rubYellow
                    }
                    
                    box.materials = [greenMaterial, redMaterial, blueMaterial, orangeMaterial, whiteMaterial, yellowMaterial]
                    
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(x, y, z)
                    
                    addChildNode(node)
                }
            }
        }
        
        scramble()
    }
    
    func scramble() {
        for _ in 0...20 {
            
            for _ in 0...2 {
                var coordinate: Coordinate!
                let randomLevel = Float(Int(arc4random_uniform(3)) - 1)
                let randomTwist = Float(Int(arc4random_uniform(3)))
                var axis = SCNVector4()
                
                if randomTwist == 0 {
                    coordinate = .yRow(self, randomLevel)
                    axis = SCNVector4(x: 0, y: 1, z: 0, w: Float.randomRotation())
                } else if randomTwist == 1 {
                    coordinate = .xCol(self, randomLevel)
                    axis = SCNVector4(x: 1, y: 0, z: 0, w: Float.randomRotation())
                } else if randomTwist == 2 {
                    coordinate = .zCol(self, randomLevel)
                    axis = SCNVector4(x: 0, y: 0, z: 1, w: Float.randomRotation())
                }
                
                let container = coordinate.container()
                container.rotation = axis
                for node in container.childNodes {
                    node.transform = container.convertTransform(node.transform, to: self)
                    self.addChildNode(node)
                }
                container.removeFromParentNode()
            }
        }
        
    }
    
    func snap(container: SCNNode, vertical: Bool, side: Side, finished: @escaping () -> ()) {
        self.animating = true
        
        let round = Int((abs(offset).truncatingRemainder(dividingBy: 360)) / 90.0 + 0.5) * 90
        
        let roundedOffset = Float(round) * Float(Double.pi / 180) * (offset < 0 ? -1 : 1)
        
        var rot: SCNVector4!
        
        if vertical {
            if side == .left || side == .right {
                rot = SCNVector4(x: 0, y: 0, z: 1, w: roundedOffset)
            } else {
                rot = SCNVector4(x: 1, y: 0, z: 0, w: roundedOffset)
            }
        } else {
            rot = SCNVector4(x: 0, y: 1, z: 0, w: roundedOffset)
        }
        
        container.runAction(SCNAction.sequence([SCNAction.rotate(toAxisAngle: rot, duration: 0.2), SCNAction.run({ (node) in
            finished()
            self.animating = false
        })]))
    }
    
    func doRotation(container: SCNNode, dirction: MoveDirection, selectedSide: Side, finished: @escaping () -> ()) {
        self.animating = true
        
//        public func truncatingRemainder(dividingBy other: Self) -> Self,返回对应的余数，类似取模运算
        //对应的移动0.05，距离，相当于90度
        let distanceFor90:CGFloat = 0.15
        let remainder = abs(offset/distanceFor90).truncatingRemainder(dividingBy:(distanceFor90*4))
        let round = Int(remainder/distanceFor90 + 0.5)*90
        
//        let round = Int((abs(offset/0.05).truncatingRemainder(dividingBy: 0.2)) / 90.0 + 0.5) * 90
        
        let roundedOffset = Float(round) * Float(Double.pi / 180) * (offset < 0 ? -1 : 1)
        
        var rotation: SCNVector4?
        
        if dirction == .xPositive || dirction == .xNegative {
            if selectedSide == .top {//绕z轴旋转
                rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(-roundedOffset))
            } else if  selectedSide == .bottom {
                rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(roundedOffset))
            } else if selectedSide == .front {//绕y轴旋转
                rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(roundedOffset))
            } else if selectedSide == .back {
                 rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(-roundedOffset))
            }
        } else if dirction == .yPositive || dirction == .yNegative{
            if selectedSide == .front { //绕x轴旋转
                rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-roundedOffset))
            } else if selectedSide == .back {
                rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(roundedOffset))
            } else if selectedSide == .right{//绕z轴旋转
                rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(roundedOffset))
            } else if selectedSide == .left {
                rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(-roundedOffset))
            }
        } else if dirction == .zPositive || dirction == .zNegative {
            if selectedSide == .top {//绕x轴旋转
                rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(roundedOffset))
            } else if selectedSide == .bottom {
                rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-roundedOffset))
            } else if selectedSide == .right {//绕y轴旋转
                rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(-roundedOffset))
            } else if selectedSide == .left {
                rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(roundedOffset))
            }
        }
        if let rot = rotation {
            container.runAction(SCNAction.sequence([SCNAction.rotate(toAxisAngle: rot, duration: 0.5), SCNAction.run({ (node) in
                finished()
                self.animating = false
            })]))
        } else {
            print("error dirction and selectedSide",dirction,selectedSide)
            finished()
            self.animating = false
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
