//
//  SwiftAsyncUDPSocket+Multicast.swift
//  SwiftAsyncSocket iOS
//
//  Created by Di on 2019/1/17.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

// MARK: - Multicast
extension SwiftAsyncUDPSocket {
    func preJoin() throws {
        try preOpen()

        guard flags.contains(.didBind) else {
            throw SwiftAsyncSocketError.badConfig(msg:
                "Must bind a socket before joining a multicast group.")
        }

        guard !flags.contains(.connecting) && flags.contains(.didConnect) else {
            throw SwiftAsyncSocketError.badConfig(msg:
                "Cannot join a multicast group if connected.")
        }
    }

    func join(multiscast group: String,
              interface: String? = nil) throws {

    }

    enum MulticastType {
        case join, leave

        var rawValue: Int32 {
            switch self {
            case .join:
                return IP_ADD_MEMBERSHIP
            case .leave:
                return IP_DROP_MEMBERSHIP
            }
        }
    }

    func perform(group: String,
                 interface: String?) throws {
        try preJoin()

        let groupAddr = try SocketDataType.lookup(host: group, port: 0,
                                                  hasNumeric: true, isTCP: false)
    }
}
