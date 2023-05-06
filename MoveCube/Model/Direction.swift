//
//  Direction.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI

enum Direction {
    case left, right, forward, back
}

//MARK: Computed properties:
extension Direction {
    
    var image: Image {
        switch self {
        case .left:
            return Image(systemName: "arrow.left.circle")
        case .right:
            return Image(systemName: "arrow.right.circle")
        case .forward:
            return Image(systemName: "arrow.down.circle")
        case .back:
            return Image(systemName: "arrow.up.circle")
        }
    }
    
}
