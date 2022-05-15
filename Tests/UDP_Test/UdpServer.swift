//
//  UdpServer.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/18.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
import SwiftAsyncSocket
class UdpServer {
    let port: UInt16
    let serverSocket: SwiftAsyncUDPSocket

    var didReceiveData: ((Data) -> Void)?

    init(port: UInt16) throws {
        self.port = port
        serverSocket = SwiftAsyncUDPSocket(delegate: nil, delegateQueue: DispatchQueue.main)

        serverSocket.delegate = self

        try serverSocket.bind(port: port)

        try serverSocket.receiveAlways()
    }
    
    func close() {
        serverSocket.close()
    }
}
extension UdpServer: SwiftAsyncUDPSocketDelegate {
    func updSocket(_ socket: SwiftAsyncUDPSocket,
                   didReceive data: Data,
                   from address: SwiftAsyncUDPSocketAddress,
                   withFilterContext filterContext: Any?) {
        print("Receive Data")
        didReceiveData?(data)
    }
}
