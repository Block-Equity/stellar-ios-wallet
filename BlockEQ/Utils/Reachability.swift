//
//  ConnectionMonitoring.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Network
import Alamofire

protocol ConnectionStateObservable: AnyObject {
    func connectionChanged(to state: Reachability.Connection)
}

protocol ConnectionMonitoring: AnyObject {
    var delegate: ConnectionStateObservable? { get set }

    func start()
    func stop()
}

final class Reachability: ConnectionMonitoring {
    enum Connection {
        case available(ConnectionType)
        case none
    }

    enum ConnectionType {
        case wifi
        case cellular
        case wired
        case other
    }

    let monitor: ConnectionMonitoring?

    var delegate: ConnectionStateObservable? {
        set { monitor?.delegate = newValue }
        get { return monitor?.delegate }
    }

    init() {
        if #available(iOS 12.0, *) {
            monitor = NetworkMonitor()
        } else {
            monitor = AlamofireReachabilityWrapper()
        }
    }

    func start() {
        monitor?.start()
    }

    func stop() {
        monitor?.stop()
    }
}

extension Reachability.ConnectionType {
    @available (iOS 12.0, *)
    init(interfaceType: NWInterface.InterfaceType) {
        switch interfaceType {
        case .cellular: self = .cellular
        case .wifi: self = .wifi
        case .wiredEthernet: self = .wired
        default: self = .other
        }
    }
}

extension Reachability.ConnectionType {
    init(connectionType: NetworkReachabilityManager.ConnectionType) {
        switch connectionType {
        case .ethernetOrWiFi: self = .wifi
        case .wwan: self = .cellular
        }
    }
}

@available(iOS 12.0, *)
final class NetworkMonitor: ConnectionMonitoring {
    let pathMonitor = NWPathMonitor()
    let dispatchQueue = DispatchQueue.main

    weak var delegate: ConnectionStateObservable?

    init() {
        pathMonitor.pathUpdateHandler = { [unowned self] path in
            switch path.status {
            case .satisfied:
                let type = Reachability.ConnectionType(interfaceType: path.availableInterfaces.first!.type)
                self.delegate?.connectionChanged(to: .available(type))
            default:
                self.delegate?.connectionChanged(to: .none)
            }
        }
    }

    func start() {
        pathMonitor.start(queue: dispatchQueue)
    }

    func stop() {
        pathMonitor.cancel()
    }
}

final class AlamofireReachabilityWrapper: ConnectionMonitoring {
    weak var delegate: ConnectionStateObservable?
    let reachability: NetworkReachabilityManager

    init() {
        guard let nrManager = NetworkReachabilityManager() else {
            fatalError("Unable to monitor local network interface")
        }

        reachability = nrManager

        nrManager.listener = { [unowned self] status in
            switch status {
            case .reachable(let connectionType):
                let type = Reachability.ConnectionType(connectionType: connectionType)
                self.delegate?.connectionChanged(to: .available(type))
            default:
                self.delegate?.connectionChanged(to: .none)
            }
        }
    }

    func start() {
        reachability.startListening()
    }

    func stop() {
        reachability.stopListening()
    }
}
