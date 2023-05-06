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
    
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
        focusEntity = FocusEntity(on: self, focus: .classic)
        configure()
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
}
