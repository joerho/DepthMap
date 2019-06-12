//
//  ARViewController.swift
//  DepthMap
//
//  Created by joe rho on 5/29/19.
//  Copyright © 2019 joe rho. All rights reserved.

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UITextView!
    
//    var imagePicker: UIImagePickerController!
    var box: Box!
    var status: String!
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    var configuration: ARWorldTrackingConfiguration!
    enum Mode {
        case waitingForMeasuring
        case measuring
    }
    
    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                status = "NOT READY"
            case .measuring:
                box.update(minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
                box.isHidden = false
                startPosition = nil
                distance = 0.0
                setStatusText()
            }
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "customCamera", sender: nil)
    }
    
    
    @IBAction func changeValue(_ sender: UISwitch) {
        if sender.isOn {
            mode = .measuring
        } else {
            mode = .waitingForMeasuring
        }
    }
    
    func setStatusText() {
        var text = "Status: \(status!)\n"
        text += "Tracking: \(getTrackigDescription())\n"
        text += "Distance: \(String(format:"%.2f cm", distance * 100.0))\n"
        text += "Start: \(String(describing: startPosition))"
        statusTextView.text = text
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "TRACKING NORMAL"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description = "TRACKING LIMITED - Too much camera movement"
                case .insufficientFeatures:
                    description = "TRACKING LIMITED - Not enough surface detail"
                case .initializing:
                    description = "INITIALIZING"
                case .relocalizing:
                    description = "relocalizing"
                }
            }
        }
        return description
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Set a padding in the text view
        statusTextView.textContainerInset = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 10.0, right: 0.0)
        // Instantiate the box and add it to the scene
        box = Box()
        box?.isHidden = true;
        sceneView.scene.rootNode.addChildNode(box!)
        // Set the initial mode
        mode = .waitingForMeasuring
        // Set the initial distance
        distance = 0.0
        // Display the initial status
        setStatusText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration with plane detection
        configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the method asynchronously to perform
        //  this heavy task without slowing down the UI
        DispatchQueue.main.async {
            self.measure()
        }
    }
    func measure() {
        let screenCenter : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        let planeTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        
        if let result = planeTestResults.first {
            status = "READY"
            if mode == .measuring {
                status = "MEASURING"
                let worldPosition = SCNVector3Make(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y,
                    result.worldTransform.columns.3.z)
                if startPosition == nil {
                    startPosition = worldPosition
                    box.position = worldPosition
                }
                distance = calculateDistance(from: startPosition, to: worldPosition)
                box.resizeTo(extent: distance!)
                let angleInRadians = calculateAngleInRadians(from: startPosition!, to: worldPosition)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
                setStatusText()
            }
        }
        else {
            status = "NOT READY"
        }
    }
//    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed. Changing worldAlignment property.")
        print(error.localizedDescription)
        
        if let arError = error as? ARError {
            switch arError.errorCode {
            case 102:
                configuration.worldAlignment = .gravity
                restartSessionWithoutDelete()
            default:
                restartSessionWithoutDelete()
            }
        }
    }
    func restartSessionWithoutDelete() {
        // Restart session with a different worldAlignment - prevents bug from crashing app
        self.sceneView.session.pause()
        
        self.sceneView.session.run(configuration, options: [
            .resetTracking,
            .removeExistingAnchors])
    }
    
    
}

func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
    let x = from.x - to.x
    let y = from.y - to.y
    let z = from.z - to.z
    return sqrtf( (x * x) + (y * y) + (z * z))
}

func calculateAngleInRadians(from: SCNVector3, to: SCNVector3) -> Float {
    let x = from.x - to.x
    let z = from.z - to.z
    return atan2(z, x)
}



