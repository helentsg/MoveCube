//
//  MovementButtonsView.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct MovementButtonsView: View {
    @Binding var cupsCounter: Int
    
    var body: some View {
        HStack() {
            Spacer()
            VStack {
                CupsCounterView(cupsCounter: $cupsCounter)
                Spacer()
            }
        }
    }
    
}
