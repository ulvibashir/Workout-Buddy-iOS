import SwiftUI
import Network

// MARK: - NetworkMonitor
// This file was CheatsheetView.swift — repurposed as network connectivity monitor.

@Observable
final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.ulvi.workoutbuddy.network")

    var isConnected: Bool = true
    var connectionType: ConnectionType = .wifi

    enum ConnectionType {
        case wifi, cellular, unknown
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else {
                    self?.connectionType = .unknown
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
