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
                MovementButtonsView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                     selectedFrame: $viewModel.selectedFrame,
                                     message: $viewModel.message)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
