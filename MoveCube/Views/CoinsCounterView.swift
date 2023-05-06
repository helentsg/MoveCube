//
//  CoinsCounterView.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct CoinsCounterView: View {
    
    @Binding var coinsCounter: Int
    
    var body: some View {
        HStack(spacing: 4) {
            AsyncImage(url: URL(string: "https://mix-ar.ru/content/ios/marker.jpg")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 80, height: 80)
                } else if phase.error != nil {
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                } else {
                    ProgressView()
                }
            }
            Text(String(coinsCounter))
                .font(.title)
        }
    }
    
}

