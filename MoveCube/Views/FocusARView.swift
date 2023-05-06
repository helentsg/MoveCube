//
//  ARFrame.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI
import Combine
import ARKit
import RealityKit
import FocusEntity

class FocusARView: ARView {
    var focusEntity: FocusEntity?
    var cupEntity: ModelEntity?
    
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
        focusEntity = FocusEntity(on: self, focus: .classic)
        focusEntity?.setAutoUpdate(to: true)
        configure()
        enableTapGesture()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder){
        fatalError("init(:coder) hasn't been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        session.run(config)
    }
    
    func enableTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.addGestureRecognizer(tapGesture)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "cup" {
            let randomColor = [UIColor.yellow, UIColor.orange, UIColor.systemPink, UIColor.blue, UIColor.green, UIColor.purple, UIColor.red, UIColor.lightGray, UIColor.white].randomElement() ?? .green
            let material = SimpleMaterial(color: randomColor, isMetallic: false)
            entity.model?.materials = [material]
        } else {
            let results = self.raycast(from: tapLocation,
                                       allowing: .estimatedPlane,
                                       alignment: .horizontal)
            if let result = results.first {
                let worldPosition = simd_make_float3(result.worldTransform.columns.3)
                if let copy = cupEntity?.clone(recursive: true) as? ModelEntity{
                    placeObject(copy, at: worldPosition)
                }
            }
        }
        
    }
    
    @IBAction func handleLongTapGesture(recognizer: UILongPressGestureRecognizer) {
        let gestureLocation = recognizer.location(in: self)
        if  let entity = entity(at: gestureLocation) {
            if let anchor = entity.anchor,
               anchor.name == "cup" {
                anchor.removeFromParent()
            }
        } else {
            
        }
    }
    
    func placeObject(_ object: ModelEntity, at location: SIMD3<Float>) {
        object.generateCollisionShapes(recursive: true)
        let objectAnchor = AnchorEntity(world: location)
        objectAnchor.name = "cup"
        objectAnchor.addChild(object)
        installGestures(.all, for: object)
        scene.anchors.append(objectAnchor)
    }
    
}
