//
//  SpinComponent.swift
//  Soccer Game
//
//  Created by Dylan F. D'anna on 4/24/25.
//

import RealityKit

/// A component that spins the entity around a given axis.
struct SpinComponent: Component {
    let spinAxis: SIMD3<Float> = [0, 1, 0]
}
