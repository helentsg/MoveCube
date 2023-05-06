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
   
    func makeUIView(context: Context) -> ARView {
        let arView = FocusARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}
