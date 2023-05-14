//
//  PlaneEntity.swift
//  MoveCube
//
//  Created by Elena Lucher on 14.5.23..
//

import UIKit
import RealityKit

/// Defines a plane entity to be used as a ground plane, providing a stable platform for the movable
/// entities, regardless of the size or shape of detected surfaces in the scene.
class PlaneEntity: Entity, HasModel, HasPhysics, HasCollision {
    
    required init() {
        super.init()
        
        let mesh = MeshResource.generatePlane(width: 20, depth: 20)
        let materials = [UnlitMaterial(color: .clear)]
        model = ModelComponent(mesh: mesh, materials: materials)
        generateCollisionShapes(recursive: true)
        physicsBody = PhysicsBodyComponent()
        physicsBody?.mode = .static
    }
    
}
