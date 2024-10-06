//
//  ConnectivityManager.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation
import Network
protocol ConnectivityManagerProtocol {
    func checkInternetConnection(completion: @escaping (Bool) -> Void)
}
class ConnectivityManager: ConnectivityManagerProtocol {
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
                monitor.cancel()
            }
        }
        monitor.start(queue: .main)
    }
}
