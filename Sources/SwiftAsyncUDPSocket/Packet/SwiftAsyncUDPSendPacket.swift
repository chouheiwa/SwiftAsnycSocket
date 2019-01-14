//
//  SwiftAsyncUDPSendPacket.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/10.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

class SwiftAsyncUDPSendPacket: SwiftAsyncUDPPacket {
    let buffer: Data

    let timeout: TimeInterval

    var tag: Int

    var resolveInProgress: Bool = false

    var filterInProgress: Bool = false

    var resolvedAddresses: [Any] = []

    var resolvedError: SwiftAsyncSocketError?

    var address: Data?

    var addressFamily: Int32 = 0

    init(buffer: Data, timeout: TimeInterval, tag: Int) {
        self.buffer = buffer
        self.timeout = timeout
        self.tag = tag
    }
}
