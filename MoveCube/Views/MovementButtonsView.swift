//
//  MovementButtonsView.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct MovementButtonsView: View {
    @Binding var coinsCounter: Int
    @Binding var selectedDirection: Direction?
    
    var body: some View {
        ZStack {
            VStack {
                MovementButton(selectedDirection: $selectedDirection,
                                                   direction: .back)
                
                Spacer()
                HStack() {
                    MovementButton(selectedDirection: $selectedDirection,
                                   direction: .left)
                    Spacer()
                    MovementButton(selectedDirection: $selectedDirection,
                                   direction: .right)
                }
                Spacer()
                MovementButton(selectedDirection: $selectedDirection,
                               direction: .forward)
            }
            HStack() {
                Spacer()
                VStack {
                    CoinsCounterView(coinsCounter: $coinsCounter)
                    Spacer()
                }
            }
        }
        
    }
    
}
