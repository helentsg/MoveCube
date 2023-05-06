//
//  MoveCubeView.swift
//  MoveCube
//
//  Created by Elena Lucher on 5.5.23..
//

import SwiftUI
import RealityKit

struct MoveCubeView : View {
    
    @ObservedObject private(set) var viewModel : MoveCubeViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(coinsCounter: $viewModel.coinsCounter).edgesIgnoringSafeArea(.all)
            if viewModel.cubsCounter > 0 {
                MovementButtonsView(coinsCounter: $viewModel.coinsCounter,
                                    selectedDirection: $viewModel.selectedDirection)
            }
        }
    }
}

