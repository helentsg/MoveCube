//
//  ModelType.swift
//  MoveCube
//
//  Created by Elena Lucher on 7.5.23..
//

import Foundation

enum ModelType {
    case pot, cup
}

//MARK: Computed properties:
extension ModelType {
    
    var name: String {
        switch self {
        case .pot:
            return "teapot"
        case .cup:
            return "cup"
        }
    }
    
    var type: String {
        switch self {
        case .pot:
            return "usdz"
        case .cup:
            return "usdz"
        }
    }
    
    var imageLink: String {
        switch self {
        case .pot:
            return ""
        case .cup:
            return "https://developer.apple.com/augmented-reality/quick-look/models/cupandsaucer/cupandsaucer_2x.jpg"
        }
    }
    
    var modelLink: String {
        switch self {
        case .pot:
            return "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz"
        case .cup:
            return "https://developer.apple.com/augmented-reality/quick-look/models/cupandsaucer/cup_saucer_set.usdz"
        }
    }
    
}
