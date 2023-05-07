//
//  MovementButton.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct MovementButton: View {
    
    @Binding var motion: Motion?
    var direction: Direction
    
    var body: some View {
        Button {
            motion?.direction = direction
        } label: {
            direction.image
                .frame(width: 60, height: 60)
                .font(.title)
                .background(Color.white.opacity(0.5))
                .cornerRadius(30)
                .padding(16)
        }
    }
    
}
