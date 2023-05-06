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
            return Image(systemName: "chevron.left")
        case .right:
            return Image(systemName: "chevron.right")
        case .forward:
            return Image(systemName: "chevron.down")
        case .back:
            return Image(systemName: "chevron.up")
        }
    }
    
}
