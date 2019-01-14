//
//  SwiftAsyncUDPSocketAddress.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/11.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

public struct SwiftAsyncUDPSocketAddress {
    public enum `Type` {
        case socket4
        case socket6
    }

    public let type: Type

    public let address: Data

    public let host: String

    public let port: UInt16

    init?(type: Type, socketFD: Int32) {
        self.type = type
        var sock: SocketAddrProtocol

        switch type {
        case .socket4:
            guard let socket = sockaddr_in.getLocalSocketFD(socketFD) else {
                return nil
            }
            sock = socket
        case .socket6:
            guard let socket = sockaddr_in6.getLocalSocketFD(socketFD) else {
                return nil
            }
            sock = socket
        }

        self.address = sock.data

        self.host = sock.host

        self.port = sock.port
    }

    init(type: Type, address: Data) {
        self.type = type
        self.address = address

        var sock: SocketAddrProtocol

        switch type {
        case .socket4:
            let socket: sockaddr_in = address.convert().pointee
            sock = socket
        case .socket6:
            let socket: sockaddr_in6 = address.convert().pointee
            sock = socket
        }

        self.host = sock.host
        self.port = sock.port
    }
}
