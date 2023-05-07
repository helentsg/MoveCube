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
    @Binding var coinsCounter: Int
    @Binding var cupsCounter: Int
    
    func makeUIView(context: Context) -> ARView {
        let arView = FocusARView(cupsCounter: $cupsCounter)
        downloadCupModel(for: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    func downloadCupModel(for arView: FocusARView) {
        let cupModel = ARModel(name: "cup",
                                      modelUrlString: "https://developer.apple.com/augmented-reality/quick-look/models/cupandsaucer/cup_saucer_set.usdz",
                                     type: "usdz")
        download(model: cupModel, for: arView)
    }
    
    func download(model: ARModel, for arView: FocusARView) {
        let desktopURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elenalucher.MoveCube")!
        let directory = desktopURL.appendingPathComponent("modelEntities")
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
        let fileOnDevice = directory.appendingPathComponent(model.name).appendingPathExtension(model.type)
        Task {
            do {
                let localTempUrl = try await tempLocalUrl(for: model.modelUrlString)
                if FileManager.default.fileExists(atPath: fileOnDevice.path) {
                    try! FileManager.default.removeItem(atPath: fileOnDevice.path)
                }
                try FileManager.default.moveItem(at: localTempUrl, to: fileOnDevice)
                DispatchQueue.main.async {
                    self.cancellable = Entity.loadModelAsync(contentsOf: fileOnDevice).sink(
                        receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                print("Unable to load a model due to \(error)")
                            }
                            self.cancellable?.cancel()
                        }, receiveValue: { model in
                            model.name = "cup"
                            arView.cupEntity = model
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
