//
//  ViewController.swift
//  Moon
//
//  Created by mahmoud on 12/3/18.
//  Copyright © 2018 mahmoud. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var moonNode:SCNNode!
    var flage = 0
    var currentAngleY:Float = 0.0
    var currentAngleX:Float = 0.0
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        createGesture()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    //MARK:- setup new gestures
    func createGesture()  {
        //TODO:- setup tap gesture .
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        //TODO:- set up pinch gesture .
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didpinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        //TODO:- set up pan gesture .
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
    }
    
    @objc func didTap(_ gesture:UITapGestureRecognizer){
        
        let moonLocation = gesture.location(in: sceneView)
        let realLocations = sceneView.hitTest(moonLocation, types: [.featurePoint])
        
        if flage == 0 {
            if let result = realLocations.first{
                let moonSphere = SCNSphere(radius: 0.2)
                let moonMaterial = SCNMaterial()
                moonMaterial.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
                moonSphere.materials = [moonMaterial]
                
                 moonNode = SCNNode(geometry: moonSphere)
                moonNode.position = SCNVector3(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y,
                    result.worldTransform.columns.3.z)
                
                sceneView.scene.rootNode.addChildNode(moonNode)
                flage = 1
            }
        }else{
            if let res = realLocations.first{
                moonNode.position = SCNVector3(res.worldTransform.columns.3.x, res.worldTransform.columns.3.y, res.worldTransform.columns.3.z)
            }
        }
       
    }
    @objc func didpinch(_ gesture:UIPinchGestureRecognizer){
        if flage == 1{
            
            var originalScale = moonNode?.scale
            switch gesture.state {
            case .began:
                originalScale = moonNode.scale
                gesture.scale = CGFloat(moonNode.scale.y)
                
            case .changed:
                guard var newScale = originalScale else {return}
                if gesture.scale < 0.5{
                    newScale = SCNVector3(0.5, 0.5, 0.5)
                }else if gesture.scale > 2 {
                    newScale = SCNVector3(2, 2, 2)
                }else{
                    newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
                }
                moonNode.scale = newScale
            case .ended:
                guard var newScale = originalScale else{return}
                if gesture.scale < 0.5 {
                    newScale = SCNVector3(0.5, 0.5, 0.5)
                }else if gesture.scale > 2 {
                    newScale = SCNVector3(2, 2, 2)
                }else{
                    newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
                }
                moonNode.scale = newScale
            default:
                gesture.scale = 1.0
                originalScale = nil
            }
        }else{
            return
        }
      
        
    }
    @objc func didPan(_ gesture:UIPanGestureRecognizer){
        
        if flage == 1{
            let translation = gesture.translation(in: sceneView)
            var newAngleY = (Float)(translation.x) * (Float)(Double.pi)/90.0
            var newAngleX = (Float)(translation.y) * (Float)(Double.pi)/90.0
            newAngleY += currentAngleY
            newAngleX += currentAngleX
            moonNode.eulerAngles.y = newAngleY
            moonNode.eulerAngles.x = newAngleX
            if gesture.state == .ended{
                currentAngleY = newAngleY
                currentAngleX = newAngleX
            }
        }else{
            return
        }
    }
    
    
    
}
