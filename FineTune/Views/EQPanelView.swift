// FineTune/Views/EQPanelView.swift
import SwiftUI

struct EQPanelView: View {
    @Binding var settings: EQSettings
    let onPresetSelected: (EQPreset) -> Void
    let onSettingsChanged: (EQSettings) -> Void

    private let frequencyLabels = ["31", "62", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]

    var body: some View {
        VStack(spacing: 8) {
            // Header: Preset picker + Bypass toggle
            HStack {
                Menu {
                    ForEach(EQPreset.allCases) { preset in
                        Button(preset.name) {
                            onPresetSelected(preset)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Preset")
                            .font(.system(size: 11))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                Spacer()

                HStack(spacing: 4) {
                    Text("EQ")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Toggle("", isOn: $settings.isEnabled)
                        .toggleStyle(.switch)
                        .scaleEffect(0.65)
                        .labelsHidden()
                        .onChange(of: settings.isEnabled) { _, _ in
                            onSettingsChanged(settings)
                        }
                }
            }

            // 10-band sliders
            HStack(spacing: 2) {
                ForEach(0..<10, id: \.self) { index in
                    EQSliderView(
                        frequency: frequencyLabels[index],
                        gain: Binding(
                            get: { settings.bandGains[index] },
                            set: { newValue in
                                settings.bandGains[index] = newValue
                                onSettingsChanged(settings)
                            }
                        )
                    )
                    .frame(width: 24, height: 70)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    EQPanelView(
        settings: .constant(EQSettings()),
        onPresetSelected: { _ in },
        onSettingsChanged: { _ in }
    )
    .frame(width: 300)
    .padding()
}
