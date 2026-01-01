// FineTune/Models/VolumeState.swift
import Foundation

@Observable
@MainActor
final class VolumeState {
    private var volumes: [pid_t: Float] = [:]
    private var pidToIdentifier: [pid_t: String] = [:]
    private let settingsManager: SettingsManager?

    init(settingsManager: SettingsManager? = nil) {
        self.settingsManager = settingsManager
    }

    func getVolume(for pid: pid_t) -> Float {
        volumes[pid] ?? 1.0
    }

    func setVolume(for pid: pid_t, to volume: Float, identifier: String? = nil) {
        volumes[pid] = volume

        if let identifier = identifier {
            pidToIdentifier[pid] = identifier
        }

        if let id = identifier ?? pidToIdentifier[pid] {
            settingsManager?.setVolume(for: id, to: volume)
        }
    }

    func loadSavedVolume(for pid: pid_t, identifier: String) -> Float? {
        pidToIdentifier[pid] = identifier
        if let saved = settingsManager?.getVolume(for: identifier) {
            volumes[pid] = saved
            return saved
        }
        return nil
    }

    func removeVolume(for pid: pid_t) {
        volumes.removeValue(forKey: pid)
        pidToIdentifier.removeValue(forKey: pid)
    }

    func cleanup(keeping pids: Set<pid_t>) {
        volumes = volumes.filter { pids.contains($0.key) }
        pidToIdentifier = pidToIdentifier.filter { pids.contains($0.key) }
    }
}
