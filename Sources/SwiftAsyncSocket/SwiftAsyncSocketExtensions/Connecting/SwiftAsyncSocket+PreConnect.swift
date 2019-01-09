//
//  SwiftAsyncSocket+PreConnect.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2018/12/19.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import Foundation

extension SwiftAsyncSocket {
    func preConnect(interface: String?) throws {
        assert(DispatchQueue.getSpecific(key: queueKey) != nil)

        try acceptDoneGuard(method: "connect")

        if let interface = interface {
            (connectInterface4, connectInterface6) = try acceptDoneInterfaceGuard(interface: interface, port: 0)
        }

        readQueue.removeAll()
        writeQueue.removeAll()
    }

    func preConnect(url: URL) throws {
        assert(DispatchQueue.getSpecific(key: queueKey) != nil)

        try acceptDoneGuard(method: "connect")

        guard let interface = getInterfaceAddress(url: url) else {
            throw SwiftAsyncSocketError.badConfig(msg: "Unknown interface." +
                " Specify valid interface by name (e.g. \"en1\") or IP address.")
        }

        connectInterfaceUN = interface

        readQueue.removeAll()
        writeQueue.removeAll()
    }

}
