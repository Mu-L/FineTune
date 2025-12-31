// FineTune/Audio/AudioProcessMonitor.swift
import AppKit
import AudioToolbox
import os

@Observable
@MainActor
final class AudioProcessMonitor {
    private(set) var activeApps: [AudioApp] = []
    private nonisolated(unsafe) var timer: Timer?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FineTune", category: "AudioProcessMonitor")

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        do {
            let processIDs = try AudioObjectID.readProcessList()
            let runningApps = NSWorkspace.shared.runningApplications
            let myPID = ProcessInfo.processInfo.processIdentifier

            var apps: [AudioApp] = []

            for objectID in processIDs {
                guard objectID.readProcessIsRunning() else { continue }

                guard let pid = try? objectID.readProcessPID(), pid != myPID else { continue }

                let bundleID = objectID.readProcessBundleID()

                // Find matching running app for icon and name
                let runningApp = runningApps.first { $0.processIdentifier == pid }

                let name = runningApp?.localizedName ?? bundleID?.components(separatedBy: ".").last ?? "Unknown"
                let icon = runningApp?.icon ?? NSImage(systemSymbolName: "app.fill", accessibilityDescription: nil) ?? NSImage()

                let app = AudioApp(
                    id: pid,
                    objectID: objectID,
                    name: name,
                    icon: icon,
                    bundleID: bundleID
                )
                apps.append(app)
            }

            // Sort by name
            activeApps = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        } catch {
            logger.error("Failed to refresh process list: \(error.localizedDescription)")
        }
    }

    deinit {
        timer?.invalidate()
    }
}
