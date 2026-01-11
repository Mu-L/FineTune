// FineTune/Views/EQSliderView.swift
import SwiftUI

struct EQSliderView: View {
    let frequency: String
    @Binding var gain: Float
    let range: ClosedRange<Float> = -12...12

    var body: some View {
        VStack(spacing: 4) {
            // Vertical slider
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    // Track background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 4)

                    // Center line (0 dB marker)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 8, height: 1)

                    // Fill from center
                    let normalizedGain = CGFloat((gain - range.lowerBound) / (range.upperBound - range.lowerBound))
                    let centerY = geo.size.height / 2
                    let thumbY = geo.size.height * (1 - normalizedGain)

                    if gain != 0 {
                        let fillHeight = abs(thumbY - centerY)
                        let fillY = gain > 0 ? (thumbY + centerY) / 2 : (centerY + thumbY) / 2

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: 4, height: fillHeight)
                            .position(x: geo.size.width / 2, y: fillY)
                    }

                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                        .position(x: geo.size.width / 2, y: thumbY)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let normalized = 1 - (value.location.y / geo.size.height)
                                    let clamped = min(max(normalized, 0), 1)
                                    gain = Float(clamped) * (range.upperBound - range.lowerBound) + range.lowerBound
                                }
                        )
                }
                .frame(maxWidth: .infinity)
            }

            // Frequency label
            Text(frequency)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .onTapGesture(count: 2) {
            withAnimation(.easeInOut(duration: 0.15)) {
                gain = 0  // Double-tap to reset
            }
        }
    }
}

#Preview {
    HStack(spacing: 4) {
        EQSliderView(frequency: "31", gain: .constant(6))
        EQSliderView(frequency: "1k", gain: .constant(0))
        EQSliderView(frequency: "16k", gain: .constant(-6))
    }
    .frame(width: 100, height: 100)
    .padding()
}
