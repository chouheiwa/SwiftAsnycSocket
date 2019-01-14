//
//  SwiftAsyncUDPSocket+Utilities.swift
//  SwiftAsyncSocket iOS
//
//  Created by Di on 2019/1/13.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

extension SwiftAsyncUDPSocket {
    func preOpen() throws {
        assert(DispatchQueue.getSpecific(key: queueKey) != nil,
               "Must be dispatched on socketQueue")

        guard delegate != nil else {
            throw SwiftAsyncSocketError.badConfig(msg:
                "Attempting to use socket without a delegate. Set a delegate first.")
        }

        guard delegateQueue != nil else {
            throw SwiftAsyncSocketError.badConfig(msg:
                "Attempting to use socket without a delegate queue. Set a delegate queue first.")
        }
    }

    func asyncResolved(host: String, port: UInt16,completionBlock: @escaping (SocketDataType?, SwiftAsyncSocketError?) -> Void ) {
        DispatchQueue.global().async {
            do {
                let result = try SocketDataType.lookup(host: host, port: port, isTCP: false)

                self.socketQueueDo(async: true, {
                    completionBlock(result, nil)
                })
            } catch let error as SwiftAsyncSocketError {
                self.socketQueueDo(async: true, {
                    completionBlock(nil, error)
                })
            } catch {
                assert(false, "\(error)")
            }
        }
    }

    func get(from type: SocketDataType) throws -> SwiftAsyncUDPSocketAddress {
        let isIPv4Deactivated = flags.contains(.IPv4Deactivated)
        let isIPv6Deactivated = flags.contains(.IPv6Deactivated)

        let judgeIPv4 = {
            guard self.isIPv4Enable else {
                throw SwiftAsyncSocketError(msg: "IPv4 has been disabled and DNS lookup found no IPv6 address(es).")
            }
            guard !isIPv4Deactivated else {
                throw SwiftAsyncSocketError(msg: "IPv4 has been deactivated due to bind/connect, and DNS lookup found no IPv6 address(es).")
            }
        }

        let judgeIPv6 = {
            guard self.isIPv6Enable else {
                throw SwiftAsyncSocketError(msg: "IPv6 has been disabled and DNS lookup found no IPv4 address(es).")
            }
            guard !isIPv6Deactivated else {
                throw SwiftAsyncSocketError(msg: "IPv6 has been deactivated due to bind/connect, and DNS lookup found no IPv4 address(es).")
            }
        }

        switch type {
        case .IPv4Data(let data):
            try judgeIPv4()

            return SwiftAsyncUDPSocketAddress(type: .socket4, address: data)
        case .IPv6Data(let data):
            try judgeIPv6()

            return SwiftAsyncUDPSocketAddress(type: .socket6, address: data)
        case .bothData(let ipv4, let ipv6):
            if isIPv4Preferred || !isIPv6Preferred {
                return SwiftAsyncUDPSocketAddress(type: .socket4, address: ipv4)
            } else {
                return SwiftAsyncUDPSocketAddress(type: .socket6, address: ipv6)
            }
        }
    }

    func convert(interface: String?,
                 port: UInt16) {
        
    }
}
