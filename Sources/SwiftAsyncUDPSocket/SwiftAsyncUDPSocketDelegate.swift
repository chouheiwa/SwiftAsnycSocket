//
//  SwiftAsyncUDPSocketDelegate.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/10.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

public protocol SwiftAsyncUDPSocketDelegate: class {
    func updSocket(_ socket: SwiftAsyncUDPSocket, didConnectTo address: Data)

    func updSocket(_ socket: SwiftAsyncUDPSocket, didNotConnect error: SwiftAsyncSocketError?)

    func updSocket(_ socket: SwiftAsyncUDPSocket, didSendDataWith tag: Int)

    func updSocket(_ socket: SwiftAsyncUDPSocket,
                   didSendDataWith tag: Int,
                   dueTo error: SwiftAsyncSocketError?)

    func updSocket(_ socket: SwiftAsyncUDPSocket,
                   fromAddress: Data,
                   withFilterContext filterContext: Any?)

    func updSocket(_ socket: SwiftAsyncUDPSocket, didCloseWith error: SwiftAsyncSocketError?)
}

public extension SwiftAsyncSocketDelegate {
    func updSocket(_ socket: SwiftAsyncUDPSocket, didConnectTo address: Data) {}

    func updSocket(_ socket: SwiftAsyncUDPSocket, didNotConnect error: SwiftAsyncSocketError?) {}

    func updSocket(_ socket: SwiftAsyncUDPSocket, didSendDataWith tag: Int) {}

    func updSocket(_ socket: SwiftAsyncUDPSocket,
                   didSendDataWith tag: Int,
                   dueTo error: SwiftAsyncSocketError?) {}

    func updSocket(_ socket: SwiftAsyncUDPSocket,
                   fromAddress: Data,
                   withFilterContext filterContext: Any?) {}

    func updSocket(_ socket: SwiftAsyncUDPSocket, didCloseWith error: SwiftAsyncSocketError?) {}
}
