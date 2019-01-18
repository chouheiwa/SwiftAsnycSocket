//
//  SwiftAsyncUDPSocket+Send.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/18.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
// MARK: - Send
extension SwiftAsyncUDPSocket {
    public func send(data: Data,
                     timeout: TimeInterval = -1,
                     tag: Int) {
        guard data.count > 0 else {
            return
        }

        let packet = SwiftAsyncUDPSendPacket(buffer: data, timeout: timeout, tag: tag)

        socketQueueDo(async: true, {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        })
    }

    public func send(data: Data,
                     toHost: String,
                     port: UInt16,
                     timeout: TimeInterval = -1,
                     tag: Int) {
        guard data.count > 0 else {
            return
        }

        let packet = SwiftAsyncUDPSendPacket(buffer: data, timeout: timeout, tag: tag)

        packet.resolveInProgress = true

        asyncResolved(host: toHost, port: port) {
            packet.resolveInProgress = false

            packet.resolvedAddresses = $0
            packet.resolvedError = $1

            if packet == self.currentSend {
                self.doPreSend()
            }
        }

        socketQueueDo(async: true, {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        })
    }

    public func send(data: Data,
                     address: Data,
                     timeout: TimeInterval = -1,
                     tag: Int) throws {
        guard data.count > 0 else {
            return
        }

        let packet = SwiftAsyncUDPSendPacket(buffer: data, timeout: timeout, tag: tag)

        packet.resolvedAddresses = try SocketDataType(data: address)

        socketQueueDo(async: true, {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        })
    }

    public func setSendFilter(_ filter: SwiftAsyncUDPSocketSendFilter) {
        socketQueueDo(async: true, {
            self.sendFilter = filter
        })
    }
}
