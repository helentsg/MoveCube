//
//  CupsCounterView.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

struct CupsCounterView: View {
    
    @Binding var cupsCounter: Int
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: ModelType.cup.imageLink)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                        .padding(8)
                } else if phase.error != nil {
                    Image(systemName: "cup.and.saucer")
                        .resizable()
                        .frame(width: 40, height: 40)
                } else {
                    ProgressView()
                }
            }
            Text("\(cupsCounter)")
                .font(.title)
                .foregroundColor(.blue)
                .padding(8)
        }
        .background(Color.white.opacity(0.5))
        .cornerRadius(5)
        .padding(16)
    }
    
}

