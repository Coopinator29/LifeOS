//
//  GymReactorRing.swift
//  LifeOS
//
//  Created by Jay Cooper on 12/03/2026.
//


import SwiftUI

struct GymReactorRing: View {
    let totalKG: Double
    let goalKG: Double
    var size: CGFloat = 170

    private var progress: Double {
        guard goalKG > 0 else { return 0 }
        return min(totalKG / goalKG, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(StarkTheme.steel.opacity(0.20), lineWidth: ringLineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            StarkTheme.arcBlue.opacity(0.24),
                            StarkTheme.ember,
                            .white.opacity(0.78),
                            StarkTheme.arcBlue,
                            StarkTheme.ember
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: StarkTheme.arcBlue.opacity(0.34), radius: size * 0.06)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            StarkTheme.graphite,
                            StarkTheme.obsidian,
                            StarkTheme.obsidian
                        ],
                        center: .center,
                        startRadius: 16,
                        endRadius: 70
                    )
                )
                .frame(width: innerCircleSize, height: innerCircleSize)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            StarkTheme.arcBlue.opacity(0.70),
                            StarkTheme.steel.opacity(0.24)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: innerCircleSize, height: innerCircleSize)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            StarkTheme.arcBlue.opacity(0.18),
                            .clear
                        ],
                        center: .top,
                        startRadius: 1,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: highlightSize, height: highlightSize)
                .offset(y: -(size * 0.09))
                .blur(radius: 8)

            VStack(spacing: 8) {
                Image(systemName: weightSymbol(for: totalKG))
                    .font(.system(size: size * 0.16, weight: .bold))
                    .foregroundStyle(.white)

                Text("\(Int(totalKG))")
                    .font(.system(size: size * 0.13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("KG")
                    .font(.system(size: size * 0.065, weight: .semibold, design: .monospaced))
                    .foregroundStyle(StarkTheme.arcBlue.opacity(0.90))
                    .tracking(2)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: StarkTheme.arcBlue.opacity(0.14), radius: size * 0.09)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: totalKG)
    }

    private var ringLineWidth: CGFloat {
        max(size * 0.105, 10)
    }

    private var innerCircleSize: CGFloat {
        size * 0.69
    }

    private var highlightSize: CGFloat {
        size * 0.54
    }
}
