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
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        downloadPotModel(for: uiView)
    }
    
    private func downloadPotModel(for uiView: ARView) {
        let cupModel = ARModel(name: "cup",
                               modelUrlString: "https://developer.apple.com/augmented-reality/quick-look/models/redchair/cup_saucer_set.usdz",
                               type: "usdz")
        let desktopURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elenalucher.MoveCube")!
        let directory = desktopURL.appendingPathComponent("modelEntities")
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
        let fileOnDevice = directory.appendingPathComponent(cupModel.name).appendingPathExtension(cupModel.type)

        Task {
            do {
                let localTempUrl = try await tempLocalUrl(for: cupModel.modelUrlString)
                if FileManager.default.fileExists(atPath: fileOnDevice.path) {
                    try! FileManager.default.removeItem(atPath: fileOnDevice.path)
                }
                try FileManager.default.moveItem(at: localTempUrl, to: fileOnDevice)
                DispatchQueue.main.async {
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
    }
    
    private func tempLocalUrl(for remoteUrlString: String) async throws -> URL {
        guard let url = URL(string: remoteUrlString) else { throw URLError(.badURL) }
        let (dataTempFileUrl, _) = try await URLSession.shared.download(from: url)
        return dataTempFileUrl
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
