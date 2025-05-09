//
//  ContentView.swift
//  Soccer Game
//
//  Created by Dylan F. D'anna on 4/24/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        ZStack {
            RealityView { content in
                // If iOS device that is not the simulator,
                // use the spatial tracking camera.
                #if os(iOS) && !targetEnvironment(simulator)
                content.camera = .spatialTracking
                #endif
                createGameScene(content)
            }.gesture(tapEntityGesture)
            // When this app runs on macOS or iOS simulator,
            // add camera controls that orbit the origin.
            #if os(macOS) || (os(iOS) && targetEnvironment(simulator))
            .realityViewCameraControls(.orbit)
            #endif

            // Add instructions to tap the cube.
            VStack {
                Spacer()
                Text("Tap the cube to spin!")
            }.padding()
        }
    }

    /// A gesture that spins entities that have a spin component.
    var tapEntityGesture: some Gesture {
        TapGesture().targetedToEntity(where: .has(SpinComponent.self))
            .onEnded({ gesture in
                try? spinEntity(gesture.entity)
            })
    }

    /// Creates a game scene and adds it to the view content.
    ///
    /// - Parameter content: The active content for this RealityKit game.
    fileprivate func createGameScene(_ content: any RealityViewContentProtocol) {
        let boxSize: SIMD3<Float> = [0.2, 0.2, 0.2]
        // A component that shows a red box model.
        let boxModel = ModelComponent(
            mesh: .generateBox(size: boxSize),
            materials: [SimpleMaterial(color: .red, isMetallic: true)]
        )
        // Components that allow interaction and visual feedback.
        let inputTargetComponent = InputTargetComponent()
        let hoverComponent = HoverEffectComponent()

        // A component that sets the collision shape.
        let boxCollision = CollisionComponent(shapes: [.generateBox(size: boxSize)])

        // A component that stores spin information.
        let spinComponent = SpinComponent()

        // Set all the entity's components.
        let boxEntity = Entity()
        boxEntity.components.set([
            boxModel, boxCollision, inputTargetComponent, hoverComponent,
            spinComponent
        ])

        // Add the entity to the RealityView content.
        content.add(boxEntity)

        // If iOS device, except simulator.
        #if os(iOS) && !targetEnvironment(simulator)
        // Create an anchor target that is any floor surface
        // greater than or equal to a 1x1m area.
        let anchorTarget: AnchoringComponent.Target = .plane(
            .horizontal, classification: .floor,
            minimumBounds: .one
        )
        boxEntity.components.set(AnchoringComponent(anchorTarget))
        // Move boxEntity up by half the box height, so that its base is on the ground.
        boxEntity.position.y += boxSize.y / 2
        #elseif os(macOS) || os(iOS)
        // If macOS, or iOS simulator, add a perspective camera to the scene.
        let camera = Entity()
        camera.components.set(PerspectiveCameraComponent())
        content.add(camera)

        // Set the camera position and orientation.
        let cameraLocation: SIMD3<Float> = [1, 1, 2]
        camera.look(at: .zero, from: cameraLocation, relativeTo: nil)
        #endif
    }

    /// Spins an entity around the y-axis.
    /// - Parameter entity: The entity to spin.
    func spinEntity(_ entity: Entity) throws {
        // Get the entity's spin component.
        guard let spinComponent = entity.components[SpinComponent.self]
        else { return }

        // Create a spin action that makes one revolution
        // around the axis from the component.
        let spinAction = SpinAction(revolutions: 1, localAxis: spinComponent.spinAxis)

        // Create a one second animation that spins an entity.
        let spinAnimation = try AnimationResource.makeActionAnimation(
            for: spinAction,
            duration: 1,
            bindTarget: .transform
        )

        // Play the animation that spins the entity.
        entity.playAnimation(spinAnimation)
    }
}

#Preview {
    ContentView()
    
}
