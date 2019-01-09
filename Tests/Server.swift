//
//  TestServer.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2019/1/4.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
import SwiftAsyncSocket
class Server: SwiftAsyncSocketDelegate {
    var baseSocket: SwiftAsyncSocket
    /// Here we use map to help we locate which socket has already been disconnected
    var acceptSockets: [String: SwiftAsyncSocket] = [:]

    var port: UInt16

    var canAccept: Bool = false

    var canSendData: ((SwiftAsyncSocket) -> Void)?

    var didReadData: ((Data) -> Void)?

    init() {
        baseSocket = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil)

        port = UInt16.random(in: 1024..<50000)

        baseSocket.delegate = self

        do {
            canAccept = try baseSocket.accept(port: port)

            canAccept = true
        } catch let error as SwiftAsyncSocketError {
            print("\(error)")
        } catch {
            fatalError("\(error)")
        }
    }

    func socket(_ socket: SwiftAsyncSocket, didAccept newSocket: SwiftAsyncSocket) {
        /// We use a time and a random number to make key unique
        let random = Int.random(in: 0..<99999)

        let date = Date()
        let key = "\(date)\(random)"
        acceptSockets[key] = newSocket
        newSocket.userData = key
        newSocket.delegate = self
        newSocket.delegateQueue = DispatchQueue.global()
        canSendData?(newSocket)
    }

    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {

    }

    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        didReadData?(data)
    }

    func socket(_ socket: SwiftAsyncSocket?, didDisconnectWith error: SwiftAsyncSocketError?) {
        guard let key = socket?.userData as? String else { return }

        acceptSockets.removeValue(forKey: key)
    }
}
