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
    var collisionSubscriptions: [Cancellable] = []
    let plane = PlaneEntity()
    let filter = CollisionFilter(group: CollisionGroup(rawValue: 1 << 0), mask: .all)

    convenience init(potsCounter: Binding<Int>,
                     cupsCounter: Binding<Int>,
                     motion: Binding<Motion?>){
        self.init(frame: .zero)
        self.potsCounter = potsCounter
        self.cupsCounter = cupsCounter
        self.motion = motion
        focusEntity = FocusEntity(on: self, focus: .classic)
        focusEntity?.setAutoUpdate(to: true)
        setPlane()
        configure()
        enableGestures()
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
    
    func enableGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.addGestureRecognizer(tapGesture)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture))
        self.addGestureRecognizer(longPressRecognizer)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
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
    
    func setPlane() {
        plane.collision?.filter = filter
        let planeAnchor = AnchorEntity(plane: .horizontal)
        planeAnchor.addChild(plane)
        scene.addAnchor(planeAnchor)
    }
    
    func placeObject(_ object: ModelEntity,
                     at location: SIMD3<Float>,
                     type: ModelType) {
        object.generateCollisionShapes(recursive: true)
        object.physicsBody = PhysicsBodyComponent()
        object.physicsBody?.mode = .static
        object.collision?.filter = filter
        let objectAnchor = AnchorEntity(world: location)
        objectAnchor.name = type.name
        objectAnchor.addChild(object)
        installGestures(.all, for: object)
        plane.addChild(objectAnchor)
        object.physicsBody?.mode = .dynamic
        addCollisions(for: object)
    }

    func addCollisions(for modelEntity: ModelEntity) {
        collisionSubscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: modelEntity) {[weak self] event in
          guard let self,
                    let entityA = event.entityA as? ModelEntity,
            let entityB = event.entityB as? ModelEntity else {
          return
        }
            switch (entityA.name, entityB.name) {
            case (ModelType.pot.name, ModelType.cup.name):
                Player().play(sound: "water")
            case (ModelType.pot.name, ModelType.pot.name):
                Player().play(sound: "remove")
            case (ModelType.cup.name, ModelType.cup.name):
                Player().play(sound: "cups")
            case (ModelType.cup.name, ModelType.pot.name):
                Player().play(sound: "water")
            default:
                break
            }
      })
        collisionSubscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: modelEntity) {  [weak self] event in
            guard let self,
                    let entityA = event.entityA as? ModelEntity,
              let entityB = event.entityB as? ModelEntity else {
            return
          }
            switch (entityA.name, entityB.name) {
            case (ModelType.pot.name, ModelType.cup.name), (ModelType.cup.name, ModelType.pot.name):
                self.reduceCupsCounter()
            default:
                break
            }
      })
       
    }
    
    @objc
    func panned(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .ended, .cancelled, .failed:
            potEntity?.physicsBody?.mode = .dynamic
            cupEntity?.physicsBody?.mode = .dynamic
            default:
                return
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let translationGesture = gestureRecognizer as? EntityTranslationGestureRecognizer,
            let entity = translationGesture.entity as? ModelEntity else { return true }
        entity.physicsBody?.mode = .kinematic
        return true
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
    
    func reduceCupsCounter() {
        if newCupsCounter > 0 {
            newCupsCounter -= 1
            cupsCounter.wrappedValue = newCupsCounter
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
