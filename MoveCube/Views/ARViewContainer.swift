//
//  ARViewContainer.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI
import RealityKit
import Combine
import AVFoundation

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var coinsCounter: Int
    
    @State var cancellable: AnyCancellable? = nil
    
    func makeUIView(context: Context) -> ARView {
        let arView = FocusARView(frame: .zero)
        let box = createBox()
        box.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation], for: box)
        let boxAnchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0))
        boxAnchor.addChild(box)
        arView.scene.anchors.append(boxAnchor)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
      
    }
    
    func createBox() -> ModelEntity {
        let box = MeshResource.generateBox(size: 0.2)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let boxEntity = ModelEntity(mesh: box, materials: [material])
        return boxEntity
    }

}

extension ARView {
    
    func enableTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
            
        }
    }
    
    
}
