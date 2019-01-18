//
//  SwiftAsyncUDPSocket+Receive.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/18.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

// MARK: - Receive
extension SwiftAsyncUDPSocket {
    public func receiveOnce() throws {
        try socketQueueDoWithError {
            guard !flags.contains(.receiveOnce) else {
                return
            }

            guard flags.contains(.didCreatSockets) else {
                throw SwiftAsyncSocketError.badConfig(msg: "Must bind socket before you can receive data. " +
                    "You can do this explicitly via bind," +
                    " or implicitly via connect or by sending data."
                )
            }

            flags.insert(.receiveOnce)
            flags.remove(.receiveContinuous)

            // Here we use async because the caller is waiting
            socketQueue.async {
                self.doReceive()
            }
        }
    }

    public func receiveAlways() throws {
        try socketQueueDoWithError {
            guard !flags.contains(.receiveOnce) else {
                return
            }

            guard flags.contains(.didCreatSockets) else {
                throw SwiftAsyncSocketError.badConfig(msg: "Must bind socket before you can receive data. " +
                    "You can do this explicitly via bind," +
                    " or implicitly via connect or by sending data."
                )
            }

            flags.remove(.receiveOnce)
            flags.insert(.receiveContinuous)

            // Here we use async because the caller is waiting
            socketQueue.async {
                self.doReceive()
            }
        }
    }

    public func pauseReceiving() {
        socketQueueDo(async: true, {
            self.flags.remove([.receiveOnce, .receiveContinuous])

            if self.socket4FDBytesAvailable > 0 {
                self.suspendReceive4Source()
            }

            if self.socket6FDBytesAvailable > 0 {
                self.suspendReceive6Source()
            }
        })
    }

    public func setReceiveFilter(_ filter: SwiftAsyncUDPSocketReceiveFilter) {
        socketQueueDo(async: true, {
            self.receiveFilter = filter
        })
    }
}
