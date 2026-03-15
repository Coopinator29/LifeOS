//
//  Particle.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
}
