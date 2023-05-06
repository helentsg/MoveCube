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
    
    @State var cancellable: AnyCancellable? = nil
    @Binding var message: Message
    @Binding var selectedFrame: Frame?
    private let networkManager = NetworkManager()
    
    func makeUIView(context: Context) -> ARView {
        let arView = FocusARView(frame: .zero)
        video(in: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let frame = selectedFrame ?? message.frame {
            let desktopURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.elenalucher.com.ARWonder")!
            let directory = desktopURL.appendingPathComponent("modelEntities")
            
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
            let fileOnDevice = directory.appendingPathComponent(frame.name).appendingPathExtension("usdz")

            Task {
                do {
                    let localTempUrl = try await tempLocalUrl(for: frame.usdzURLString)
                    if FileManager.default.fileExists(atPath: fileOnDevice.path) {
                        try! FileManager.default.removeItem(atPath: fileOnDevice.path)
                    }
                    try FileManager.default.moveItem(at: localTempUrl, to: fileOnDevice)
                    DispatchQueue.main.async {
                        selectedFrame = nil
                        cancellable = Entity.loadModelAsync(contentsOf: fileOnDevice).sink(
                            receiveCompletion: { completion in
                                if case let .failure(error) = completion {
                                    print("Unable to load a model due to \(error)")
                                }
                                self.cancellable?.cancel()
                            }, receiveValue: { model in
                                print(model.components.count)
                                let anchor = AnchorEntity(plane: .any)
                                anchor.addChild(model)
                                uiView.scene.anchors.append(anchor)
                            })
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            print(2)
        }
    }
    
    private func tempLocalUrl(for remoteUrlString: String) async throws -> URL {
        guard let url = URL(string: remoteUrlString) else { throw URLError(.badURL) }
        let (dataTempFileUrl, _) = try await URLSession.shared.download(from: url)
        return dataTempFileUrl
    }
    
    private func video(in arView: ARView) {
        let dimensions : SIMD3<Float> = [1.23, 0.06, 0.7]
        
        // Create TV Housing
        let housingMesh = MeshResource.generateBox(size: dimensions)
        let housingMaterial = SimpleMaterial(color: .black, roughness: 0.4, isMetallic: false)
        let housingEntity = ModelEntity(mesh: housingMesh, materials: [housingMaterial])
        
        // Create TV Screen
        let screenMesh = MeshResource.generatePlane(width: dimensions.x, depth: dimensions.z)
        let screenMaterial = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
        let screenEntity = ModelEntity(mesh: screenMesh, materials: [screenMaterial])
        screenEntity.name = "tvScreen"
        
        // Add TV Screen to Housing
        housingEntity.addChild(screenEntity)
        screenEntity.setPosition([0,dimensions.y/2 + 0.001, 0], relativeTo: housingEntity)
        
        // Create Anchor to place TV on wall
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(housingEntity)
        arView.scene.addAnchor(anchor)
        arView.enableTapGesture()
        housingEntity.generateCollisionShapes(recursive: true)
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
            loadVideoMaterial(for: entity)
        }
    }
    
    func loadVideoMaterial(for entity: ModelEntity) {
        let url = Bundle.main.url(forResource: "DemoVideo", withExtension: "MP4")!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        player.play()
    }
    
}
