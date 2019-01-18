//
//  SwiftAsyncUDPSocket+Enable.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/18.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

// MARK: - Enable
extension SwiftAsyncUDPSocket {
    public func enableReusePort(isEnable: Bool) throws {
        try socketQueueDoWithError {
            try preOpen()

            if !flags.contains(.didCreatSockets) {
                try createSocket(IPv4: isIPv4Enable, IPv6: isIPv6Enable)
            }

            var value = isEnable ? 1 : 0

            let setSockopt: (Int32) throws -> Void = {
                let status = Darwin.setsockopt($0, SOL_SOCKET, SO_REUSEPORT,
                                               &value,
                                               socklen_t(MemoryLayout.size(ofValue: value)))

                guard status == 0 else {
                    throw SwiftAsyncSocketError.errno(code: errno,
                                                      reason: "Error in setsockopt() function")
                }
            }

            if socket4FD != -1 {
                try setSockopt(socket4FD)
            }

            if socket6FD != -1 {
                try setSockopt(socket6FD)
            }
        }
    }

    public func enableBroadcast(isEnable: Bool) throws {
        try preOpen()

        if !flags.contains(.didCreatSockets) {
            try createSocket(IPv4: isIPv4Enable, IPv6: isIPv6Enable)
        }
        var value = isEnable ? 1 : 0
        let setSockopt: (Int32) throws -> Void = {
            let status = Darwin.setsockopt($0, SOL_SOCKET, SO_BROADCAST,
                                           &value,
                                           socklen_t(MemoryLayout.size(ofValue: value)))

            guard status == 0 else {
                throw SwiftAsyncSocketError.errno(code: errno,
                                                  reason: "Error in setsockopt() function")
            }
        }

        if socket4FD != -1 {
            try setSockopt(socket4FD)
        }

        // IPv6 does not implement broadcast,
        // the ability to send a packet to all hosts on the attached link.
        // The same effect can be achieved by sending
        // a packet to the link-local all hosts multicast group.
    }
}
