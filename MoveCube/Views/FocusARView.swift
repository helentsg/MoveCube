//
//  ARFrame.swift
//  MoveCube
//
//  Created by Elena Lucher on 6.5.23..
//

import SwiftUI
import Combine
import ARKit
import RealityKit
import FocusEntity

class FocusARView: ARView, EventSource {
    var focusEntity: FocusEntity?
    var cupEntity: ModelEntity?
    var potEntity: ModelEntity?
    var newCupsCounter: Int = 0
    lazy var cupsCounter = Binding {
        return self.newCupsCounter
    } set: { newValue in
        self.newCupsCounter = newValue
    }
    var newPotsCounter: Int = 0
    lazy var potsCounter = Binding {
        return self.newPotsCounter
    } set: { newValue in
        self.newPotsCounter = newValue
    }
    var newMotion: Motion?
    lazy var motion = Binding {
        return self.newMotion
    } set: { newValue in
        self.newMotion = newValue
    }
    private var randomColor : UIColor {
        [UIColor.yellow, UIColor.orange, UIColor.systemPink, UIColor.blue, UIColor.green, UIColor.purple, UIColor.red, UIColor.lightGray, UIColor.white].randomElement() ?? .green
    }
    var collisionSubs: [Cancellable] = []
    let collisionGroup = CollisionGroup(rawValue: 1 << 0)
    
    convenience init(potsCounter: Binding<Int>,
                     cupsCounter: Binding<Int>,
                     motion: Binding<Motion?>){
        self.init(frame: .zero)
        self.potsCounter = potsCounter
        self.cupsCounter = cupsCounter
        self.motion = motion
        focusEntity = FocusEntity(on: self, focus: .classic)
        focusEntity?.setAutoUpdate(to: true)
        configure()
        addCollisions()
        enableTapGesture()
    }
    
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder){
        fatalError("init(:coder) hasn't been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        session.run(config)
    }
    
    func enableTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.addGestureRecognizer(tapGesture)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity {
            if entity.name == ModelType.pot.name {
                let material = SimpleMaterial(color: randomColor, isMetallic: false)
                entity.model?.materials = [material]
            } else if entity.name == ModelType.cup.name {
                Player().play(sound: "cups")
            }
        } else {
            let results = self.raycast(from: tapLocation,
                                       allowing: .estimatedPlane,
                                       alignment: .horizontal)
            if let result = results.first {
                let worldPosition = simd_make_float3(result.worldTransform.columns.3)
                if let copy = potEntity?.clone(recursive: true) as? ModelEntity {
                    placeObject(copy, at: worldPosition, type: .pot)
                    newPotsCounter += 1
                    potsCounter.wrappedValue = newPotsCounter
                    if newPotsCounter == 1 {
                        placeCups(in: worldPosition)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func handleLongTapGesture(recognizer: UILongPressGestureRecognizer) {
        let gestureLocation = recognizer.location(in: self)
        if  let entity = entity(at: gestureLocation) {
            if let anchor = entity.anchor,
               anchor.name == ModelType.pot.name {
                anchor.removeFromParent()
                newPotsCounter -= 1
                potsCounter.wrappedValue = newPotsCounter
                if newPotsCounter == 0 {
                    removeCups()
                }
            }
        } else {
            
        }
    }
    
    func placeObject(_ object: ModelEntity,
                     at location: SIMD3<Float>,
                     type: ModelType) {
        object.generateCollisionShapes(recursive: true)
        object.physicsBody = .init()
        object.physicsBody?.massProperties.mass = 5
        object.physicsBody?.mode = .kinematic
        object.collision = collision(for: type)
        let mask = CollisionGroup.all.subtracting(collisionGroup)
        let filter = CollisionFilter(group: collisionGroup,
                                                  mask: mask)
        object.collision?.filter = filter
        let objectAnchor = AnchorEntity(world: location)
        objectAnchor.name = type.name
        objectAnchor.addChild(object)
        installGestures(.all, for: object)
        scene.anchors.append(objectAnchor)
    }
    
    func collision(for type: ModelType) -> CollisionComponent {
        switch type {
        case .pot:
            return CollisionComponent(
                shapes: [ShapeResource.generateCapsule(height: 20, radius: 10)],
                mode: .trigger,
                filter: .sensor
            )
        case .cup:
            return CollisionComponent(
                shapes: [ShapeResource.generateCapsule(height: 30, radius: 20)],
                mode: .trigger,
                filter: .sensor
            )
        }
    }
    
    func addCollisions() {
      collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
          guard let entity = event.entityA as? ModelEntity else {
          return
        }

          entity.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
      })
      collisionSubs.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
          guard let entity = event.entityA as? ModelEntity else {
          return
        }
          entity.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
      })
    }
    
    func removeCups() {
        newCupsCounter = 0
        cupsCounter.wrappedValue = newCupsCounter
        let cupAnchors = scene.anchors.filter { $0.name == ModelType.cup.name }
        cupAnchors.forEach { $0.removeFromParent() }
    }
    
    func movePots(by motion: Binding<Motion?>) {
        var transform = Transform()
        guard let motion = motion.wrappedValue else { return }
        switch motion.direction {
        case .left:
            transform.translation.x = -0.5
        case .right:
            transform.translation.x = 0.5
        case .forward:
            transform.translation.z = -0.5
        case .back:
            transform.translation.z = 0.5
        }
        let potAnchors = scene.anchors.filter({ $0.name == ModelType.pot.name })
        let pots = potAnchors.compactMap { $0.children[0] as? ModelEntity }
        pots.forEach { model in
            DispatchQueue.main.async {
               
            }
        }
    }
    
    func placeCups(in location: SIMD3<Float>) {
        for _ in 0 ..< 3 {
            guard let cupModel = cupEntity?.clone(recursive: true) as? ModelEntity else {
                return
            }
            newCupsCounter += 1
            cupsCounter.wrappedValue = newCupsCounter
            let cupLocation = SIMD3(x: location.x + randomFloat(),
                                    y: location.y,
                                    z: location.z + randomFloat())
            placeObject(cupModel, at: cupLocation, type: .cup)
        }
    }
    
    func randomFloat() -> Float {
        [-0.5, -0.4, -0.3, -0.2, 0.2, 0.3, 0.4, 0.5].randomElement() ?? 0.2
    }
    
}
