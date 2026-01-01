// FineTune/Views/AppVolumeRowView.swift
import SwiftUI

struct AppVolumeRowView: View {
    let app: AudioApp
    let volume: Float  // Linear gain 0-2
    let onVolumeChange: (Float) -> Void

    @State private var sliderValue: Double  // 0-1, log-mapped position

    init(app: AudioApp, volume: Float, onVolumeChange: @escaping (Float) -> Void) {
        self.app = app
        self.volume = volume
        self.onVolumeChange = onVolumeChange
        // Convert linear gain to slider position
        self._sliderValue = State(initialValue: VolumeMapping.gainToSlider(volume))
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)

            Text(app.name)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)

            Slider(value: $sliderValue, in: 0...1)
                .frame(minWidth: 100)
                .overlay(alignment: .center) {
                    // Unity marker at center (100% = native volume)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 1, height: 8)
                        .allowsHitTesting(false)
                }
                .onChange(of: sliderValue) { _, newValue in
                    let gain = VolumeMapping.sliderToGain(newValue)
                    onVolumeChange(gain)
                }

            // Show linear percentage (0-200%) matching slider position
            Text("\(Int(sliderValue * 200))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .trailing)
        }
        .onChange(of: volume) { _, newValue in
            sliderValue = VolumeMapping.gainToSlider(newValue)
        }
    }
}
