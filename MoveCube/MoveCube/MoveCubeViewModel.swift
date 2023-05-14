//
//  MoveCubeViewModel.swift
//  MoveCube
//
//  Created by Elena Lucher on 5.5.23..
//

import SwiftUI

class MoveCubeViewModel: ObservableObject {

    @Published var potsCounter: Int = 0
    @Published var cupsCounter: Int = 0
    @Published var motion: Direction?
    
    init() {
    }
    
}


