//
//  ARFrame.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import ARKit
import RealityKit
import FocusEntity

class FocusARView: ARView {
    var focusEntity: FocusEntity?
    let networkManager = NetworkManager()
    var potsAnchor = AnchorEntity(plane: .horizontal)
    
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
        focusEntity = FocusEntity(on: self, focus: .classic)
        focusEntity?.setAutoUpdate(to: true)
        configure()
        enableTapGesture()
        downloadPotModel()
        self.scene.anchors.append(potsAnchor)
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
    }
    
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        let results = self.raycast(from: tapLocation,
                                       allowing: .estimatedPlane,
                                       alignment: .horizontal)
        if let result = results.first {
            let worldPosition = simd_make_float3(result.worldTransform.columns.3)
            
            potsAnchor.position = worldPosition
            
        }
        
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "tvScreen" {
            
        }
    }
    
    private func downloadPotModel() {
        let potModel = ARModel(name: "pot",
                               modelUrlString: "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz",
                               type: "usdz")
       networkManager.download(model: potModel, for: potsAnchor)
    }
    
//    private func downloadCupModel() {
//        let cupModel = ARModel(name: "cup",
//                               modelUrlString: "https://developer.apple.com/augmented-reality/quick-look/models/cupandsaucer/cup_saucer_set.usdz",
//                               type: "usdz")
//        networkManager.download(model: cupModel, for: potsAnchor)
//    }
    
}
