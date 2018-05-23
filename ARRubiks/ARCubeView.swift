//
//  ARCubeView.swift
//  ARRubiks
//
//  Created by Nicholas Grana on 6/10/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import ARKit

class ARCubeView: ARSCNView, UIGestureRecognizerDelegate {
    
    var cube: ARCubeNode!
    var startPanPoint: CGPoint?
    var vertical = false
    var horizontal = false
    var selectedContainer: SCNNode?
    var selectedSide: Side?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        setup()
    }
    
    
    func setup() {
        func setupCube() {
            cube = ARCubeNode()
            
//            cube.position = SCNVector3(0, -0.1, -0.3)//as the init position isn't the center,so calculat the Side error. remove this to fix side calculat result
            cube.scale = SCNVector3(0.05, 0.05, 0.05)
            
            scene.rootNode.addChildNode(cube)
        }
        func setupGestures() {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
            pan.delegate = self
            addGestureRecognizer(pan)
        }
        
        setupCube()
        setupGestures()
    }
    
    func side(from: SCNHitTestResult?) -> Side? {
        guard let from = from else {
            return nil
        }
        
        let pos = from.worldCoordinates
        let top = SCNVector3(0, 5, 0).distance(to: pos)
        let bottom = SCNVector3(0, -5, 0).distance(to: pos)
        let left = SCNVector3(-5, 0, 0).distance(to: pos)
        let right = SCNVector3(5, 0, 0).distance(to: pos)
        let back = SCNVector3(0, 0, -5).distance(to: pos)
        let front = SCNVector3(0, 0, 5).distance(to: pos)
        
        let all = [top, bottom, left, right, back, front]
        
        if top.isSmallest(from: all) {
            return .top
        } else if bottom.isSmallest(from: all) {
            return .bottom
        } else if left.isSmallest(from: all) {
            return .left
        } else if right.isSmallest(from: all) {
            return .right
        } else if back.isSmallest(from: all) {
            return .back
        } else if front.isSmallest(from: all) {
            return .front
        }
        
        return nil
    }
    
    @objc func swipe(_ gestureRecognize: UIPanGestureRecognizer) {
        if cube.animating {
            return
        }
        
        let velocity = gestureRecognize.velocity(in: self)
        let point = gestureRecognize.location(in: self)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        let isHorizontal = abs(velocity.x) > abs(velocity.y)
        let p = gestureRecognize.location(in: self)
        let hitResults = hitTest(p, options: [:])
        
        if selectedSide == nil {
            selectedSide = side(from: hitResults.first)
            
            if selectedSide == nil {
                return
            }
        }
        
        if startPanPoint == nil {
            startPanPoint = gestureRecognize.location(in: self)
        }
        
        if !vertical && !horizontal {
            vertical = isVertical
            horizontal = isHorizontal
        }
        
        // selects the col/row to be rotated
        if gestureRecognize.state == .began {
            guard let node = hitResults.first?.node else {
                return
            }
            
            if vertical {
                // change z, otherwise change y
                if selectedSide == .left || selectedSide == .right {
                    selectedContainer = Coordinate.zCol(cube, node.position.z).container()
                } else {
                    selectedContainer = Coordinate.xCol(cube, node.position.x).container()
                }
            } else {
                selectedContainer = Coordinate.yRow(cube, node.position.y).container()
            }
            cube.addChildNode(selectedContainer!)
        }
        
        // rotates col/row
        if isVertical && vertical {
            cube.offset = point.y - startPanPoint!.y // they share the same point pan
            if selectedSide == .left || selectedSide == .back {
                // switch its rotation direction
                cube.offset = startPanPoint!.y - point.y
            }
            if selectedSide == .left || selectedSide == .right {
                selectedContainer?.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(cube.offset * CGFloat(Double.pi / 180)))
            } else {
                selectedContainer?.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(cube.offset * CGFloat(Double.pi / 180)))
            }
            
        } else if isHorizontal && horizontal {
            cube.offset = point.x - startPanPoint!.x
            selectedContainer?.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(cube.offset * CGFloat(Double.pi / 180)))
        }
        
        // when it ends snap the col/row into the closest angle
        if gestureRecognize.state == .ended {
            if let container = selectedContainer {
                cube.snap(container: container, vertical: vertical, side: selectedSide!, finished: {
                    for node in self.selectedContainer?.childNodes ?? [SCNNode]() {
                        node.transform = self.selectedContainer!.convertTransform(node.transform, to: self.cube)
                        self.cube.addChildNode(node)
                    }
                    self.selectedContainer = nil
                    self.selectedSide = nil
                    self.startPanPoint = nil
                    self.vertical = false
                    self.horizontal = false
                    self.cube.offset = 0;
                    self.cube.animating = false
                })
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
