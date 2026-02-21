// FineTune/Views/EQPanelView.swift
import SwiftUI

struct EQPanelView: View {
    @Binding var settings: EQSettings
    @Binding var compressorSettings: CompressorSettings
    let onPresetSelected: (EQPreset) -> Void
    let onSettingsChanged: (EQSettings) -> Void
    let onCompressorSettingsChanged: (CompressorSettings) -> Void

    private let frequencyLabels = ["32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]

    private var currentPreset: EQPreset? {
        EQPreset.allCases.first { preset in
            preset.settings.bandGains == settings.bandGains
        }
    }

    var body: some View {
        // Entire EQ panel content inside recessed background
        VStack(spacing: 12) {
            VStack(spacing: 10) {
                // Header: Toggle left, Preset right
                HStack {
                    // EQ toggle on left
                    HStack(spacing: 6) {
                        Toggle("", isOn: $settings.isEnabled)
                            .toggleStyle(.switch)
                            .scaleEffect(0.7)
                            .labelsHidden()
                            .onChange(of: settings.isEnabled) { _, _ in
                                onSettingsChanged(settings)
                            }
                        Text("EQ")
                            .font(DesignTokens.Typography.pickerText)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Preset picker on right
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text("Preset")
                            .font(DesignTokens.Typography.pickerText)
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        EQPresetPicker(
                            selectedPreset: currentPreset,
                            onPresetSelected: onPresetSelected
                        )
                    }
                }
                .zIndex(1)  // Ensure dropdown renders above sliders

                // 10-band sliders
                HStack(spacing: 22) {
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
                        .frame(width: 26, height: 100)
                    }
                }
            }
            .padding(.bottom, 4)

            Divider()
                .overlay(DesignTokens.Colors.glassBorder)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Toggle("", isOn: $compressorSettings.isEnabled)
                            .toggleStyle(.switch)
                            .scaleEffect(0.7)
                            .labelsHidden()
                            .onChange(of: compressorSettings.isEnabled) { _, _ in
                                onCompressorSettingsChanged(compressorSettings)
                            }
                        Text("Compressor")
                            .font(DesignTokens.Typography.pickerText)
                            .foregroundColor(.primary)
                    }

                    Spacer()
                }

                compressorSlider(
                    label: "Threshold",
                    value: Binding(
                        get: { Double(compressorSettings.thresholdDB) },
                        set: { newValue in
                            compressorSettings.thresholdDB = Float(newValue)
                            onCompressorSettingsChanged(compressorSettings)
                        }
                    ),
                    range: Double(CompressorSettings.minThresholdDB)...Double(CompressorSettings.maxThresholdDB),
                    step: 1.0,
                    valueSuffix: " dB"
                )

                compressorSlider(
                    label: "Ratio",
                    value: Binding(
                        get: { Double(compressorSettings.ratio) },
                        set: { newValue in
                            compressorSettings.ratio = Float(newValue)
                            onCompressorSettingsChanged(compressorSettings)
                        }
                    ),
                    range: Double(CompressorSettings.minRatio)...Double(CompressorSettings.maxRatio),
                    step: 0.1,
                    valueSuffix: ":1"
                )

                compressorSlider(
                    label: "Attack",
                    value: Binding(
                        get: { Double(compressorSettings.attackMs) },
                        set: { newValue in
                            compressorSettings.attackMs = Float(newValue)
                            onCompressorSettingsChanged(compressorSettings)
                        }
                    ),
                    range: Double(CompressorSettings.minAttackMs)...Double(CompressorSettings.maxAttackMs),
                    step: 0.1,
                    valueSuffix: " ms"
                )

                compressorSlider(
                    label: "Release",
                    value: Binding(
                        get: { Double(compressorSettings.releaseMs) },
                        set: { newValue in
                            compressorSettings.releaseMs = Float(newValue)
                            onCompressorSettingsChanged(compressorSettings)
                        }
                    ),
                    range: Double(CompressorSettings.minReleaseMs)...Double(CompressorSettings.maxReleaseMs),
                    step: 1.0,
                    valueSuffix: " ms"
                )

                compressorSlider(
                    label: "Makeup",
                    value: Binding(
                        get: { Double(compressorSettings.makeupGainDB) },
                        set: { newValue in
                            compressorSettings.makeupGainDB = Float(newValue)
                            onCompressorSettingsChanged(compressorSettings)
                        }
                    ),
                    range: Double(CompressorSettings.minMakeupGainDB)...Double(CompressorSettings.maxMakeupGainDB),
                    step: 0.5,
                    valueSuffix: " dB"
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignTokens.Colors.recessedBackground)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        // No outer background - parent ExpandableGlassRow provides the glass container
    }

    @ViewBuilder
    private func compressorSlider(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        valueSuffix: String
    ) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Text(label)
                .font(DesignTokens.Typography.caption)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .frame(width: 72, alignment: .leading)

            Slider(value: value, in: range, step: step)
                .controlSize(.small)

            Text("\(value.wrappedValue, specifier: "%.1f")\(valueSuffix)")
                .font(DesignTokens.Typography.caption)
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .monospacedDigit()
                .frame(width: 78, alignment: .trailing)
        }
    }
}

#Preview {
    // Simulating how it appears inside ExpandableGlassRow
    VStack {
        EQPanelView(
            settings: .constant(EQSettings()),
            compressorSettings: .constant(CompressorSettings()),
            onPresetSelected: { _ in },
            onSettingsChanged: { _ in },
            onCompressorSettingsChanged: { _ in }
        )
    }
    .padding(.horizontal, DesignTokens.Spacing.sm)
    .padding(.vertical, DesignTokens.Spacing.xs)
    .background {
        RoundedRectangle(cornerRadius: DesignTokens.Dimensions.rowRadius)
            .fill(DesignTokens.Colors.recessedBackground)
    }
    .frame(width: 550)
    .padding()
    .background(Color.black)
}
