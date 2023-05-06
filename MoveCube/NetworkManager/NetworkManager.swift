//
//  NetworkManager.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI
import RealityKit
import Combine

class NetworkManager {
    
    @State var cancellable: AnyCancellable? = nil
    
    func download(model: ARModel, for anchor: AnchorEntity) {
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
                DispatchQueue.main.async { [weak self] in
                    self?.cancellable = Entity.loadModelAsync(contentsOf: fileOnDevice).sink(
                        receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                print("Unable to load a model due to \(error)")
                            }
                            self?.cancellable?.cancel()
                        }, receiveValue: { model in
                            print(model.components.count)
                            anchor.addChild(model)
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
