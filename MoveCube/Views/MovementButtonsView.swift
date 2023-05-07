//
//  MovementButtonsView.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct MovementButtonsView: View {
    @Binding var coinsCounter: Int
    @Binding var motion: Motion?
    
    var body: some View {
        ZStack {
            VStack {
                MovementButton(motion: $motion,
                               direction: .back)
                Spacer()
                HStack() {
                    MovementButton(motion: $motion,
                                   direction: .left)
                    Spacer()
                    MovementButton(motion: $motion,
                                   direction: .right)
                }
                Spacer()
                MovementButton(motion: $motion,
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
