//
//  ReactorView.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import SwiftUI

struct ReactorView: View {
    let tapCount: Int
    let onTap: () -> Void

    @State private var pulse = false
    @State private var reactorPulse = false
    @State private var shockwave = false
    @State private var explode = false
    @State private var particles: [Particle] = []

    var body: some View {
        ZStack {
            Circle()
                .stroke(StarkTheme.steel.opacity(0.26), lineWidth: 18)
                .frame(width: 260, height: 260)

            Circle()
                .trim(from: 0.08, to: 0.92)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            StarkTheme.arcBlue.opacity(0.28),
                            StarkTheme.ember,
                            .white.opacity(0.65),
                            StarkTheme.arcBlue,
                            StarkTheme.ember
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(color: StarkTheme.arcBlue.opacity(0.42), radius: 12)

            Circle()
                .stroke(StarkTheme.ember.opacity(0.35), lineWidth: 4)
                .frame(width: pulse ? 170 : 145, height: pulse ? 170 : 145)
                .opacity(pulse ? 0.2 : 0.6)
                .animation(
                    .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                    value: pulse
                )

            Circle()
                .stroke(StarkTheme.arcBlue.opacity(0.62), lineWidth: 3)
                .frame(width: shockwave ? 300 : 120, height: shockwave ? 300 : 120)
                .opacity(shockwave ? 0 : 0.7)
                .blur(radius: shockwave ? 2 : 0)

            Circle()
                .stroke(StarkTheme.steel.opacity(0.34), lineWidth: 2)
                .frame(width: 120, height: 120)

            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, StarkTheme.arcBlue.opacity(0.95), StarkTheme.ember.opacity(0.18)],
                            center: .center,
                            startRadius: 1,
                            endRadius: particle.size
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: explode ? cos(particle.angle) * particle.distance : 0,
                        y: explode ? sin(particle.angle) * particle.distance : 0
                    )
                    .opacity(explode ? 0 : 1)
                    .blur(radius: 0.5)
                    .animation(
                        .easeOut(duration: particle.duration).delay(particle.delay),
                        value: explode
                    )
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            StarkTheme.graphite,
                            StarkTheme.obsidian,
                            StarkTheme.obsidian
                        ],
                        center: .center,
                        startRadius: 12,
                        endRadius: 60
                    )
                )
                .frame(width: 90, height: 90)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            StarkTheme.arcBlue.opacity(0.75),
                            StarkTheme.steel.opacity(0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 90, height: 90)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            StarkTheme.arcBlue.opacity(0.22),
                            .clear
                        ],
                        center: .top,
                        startRadius: 1,
                        endRadius: 28
                    )
                )
                .frame(width: 78, height: 78)
                .offset(y: -14)
                .blur(radius: 8)

            VStack(spacing: 4) {
                Text("\(tapCount)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("TAPS")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(StarkTheme.arcBlue.opacity(0.92))
            }
            .allowsHitTesting(false)
        }
        .frame(width: 300, height: 300)
        .scaleEffect(reactorPulse ? 1.06 : 1.0)
        .shadow(color: StarkTheme.arcBlue.opacity(reactorPulse ? 0.45 : 0.14), radius: reactorPulse ? 30 : 8)
        .contentShape(Circle())
        .onTapGesture {
            onTap()
            triggerReactorEffect()
        }
        .onAppear {
            pulse = true
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.5), value: reactorPulse)
    }

    private func triggerReactorEffect() {
        particles = makeParticles()
        explode = false
        shockwave = false
        reactorPulse = false

        withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
            reactorPulse = true
        }

        withAnimation(.easeOut(duration: 0.65)) {
            shockwave = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.7)) {
                explode = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 0.22)) {
                reactorPulse = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            particles.removeAll()
            explode = false
            shockwave = false
        }
    }

    private func makeParticles() -> [Particle] {
        (0..<24).map { _ in
            Particle(
                angle: Double.random(in: 0...(Double.pi * 2)),
                distance: CGFloat.random(in: 70...140),
                size: CGFloat.random(in: 4...10),
                duration: Double.random(in: 0.35...0.75),
                delay: Double.random(in: 0...0.06)
            )
        }
    }
}
