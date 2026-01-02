// FineTune/Views/DevicePickerView.swift
import SwiftUI

struct DevicePickerView: View {
    let devices: [AudioDevice]
    let selectedDeviceUID: String?
    let onDeviceSelected: (String?) -> Void

    private var selectedDevice: AudioDevice? {
        guard let uid = selectedDeviceUID else { return nil }
        return devices.first { $0.uid == uid }
    }

    private var displayName: String {
        selectedDevice?.name ?? "System Default"
    }

    private var displayIcon: NSImage? {
        selectedDevice?.icon
    }

    var body: some View {
        Menu {
            Button {
                onDeviceSelected(nil)
            } label: {
                HStack {
                    Label("System Default", systemImage: "speaker.wave.2")
                    if selectedDeviceUID == nil {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }

            if !devices.isEmpty {
                Divider()

                ForEach(devices) { device in
                    Button {
                        onDeviceSelected(device.uid)
                    } label: {
                        HStack {
                            if let icon = device.icon {
                                Image(nsImage: icon)
                            } else {
                                Image(systemName: "hifispeaker")
                            }
                            Text(device.name)
                            if selectedDeviceUID == device.uid {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let icon = displayIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                }
                Text(displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(4)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
