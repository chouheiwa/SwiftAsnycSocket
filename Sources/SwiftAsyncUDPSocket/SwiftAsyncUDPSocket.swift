//
//  SwiftAsyncUDPSocket.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/10.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
import CFNetwork
#endif

extension SwiftAsyncSocketKeys {
    static let udpSocketQueueName = "SwiftAsyncUdpSocket"
}

public class SwiftAsyncUDPSocket: NSObject {
    weak var delegateStore: SwiftAsyncUDPSocketDelegate?

    var delegateQueueStore: DispatchQueue?

    var receiveFilter: SwiftAsyncUDPSocketReceiveFilter?

    var sendFilter: SwiftAsyncUDPSocketSendFilter?

    var flags: SwiftAsyncUdpSocketFlags = []

    var config: SwiftAsyncUdpSocketConfig = []

    var max4ReceiveSizeStore: UInt16 = 65535

    var max6ReceiveSizeStore: UInt32 = 65535

    var maxSendSizeStore: UInt16 = 65535

    var socket4FD: Int32 = SwiftAsyncSocketKeys.socketNull

    var socket6FD: Int32 = SwiftAsyncSocketKeys.socketNull

    var socketQueue: DispatchQueue

    var send4Source: DispatchSourceWrite?

    var send6Source: DispatchSourceWrite?

    var receive4Source: DispatchSourceRead?

    var receive6Source: DispatchSourceRead?

    var sendTimer: DispatchSourceTimer?

    var currentSend: SwiftAsyncUDPPacket?

    var sendQueue: [SwiftAsyncUDPPacket] = []

    var socket4FDBytesAvailable: UInt = 0

    var socket6FDBytesAvailable: UInt = 0

    var pendingFilterOperations: UInt32 = 0

    var cachedLocalAddress4: SwiftAsyncUDPSocketAddress?

    var cachedLocalAddress6: SwiftAsyncUDPSocketAddress?

    var cachedConnectedAddress: SwiftAsyncUDPSocketAddress?

    var queueKey: DispatchSpecificKey<SwiftAsyncUDPSocket> = DispatchSpecificKey<SwiftAsyncUDPSocket>()

    #if os(iOS)
    var streamContext: CFStreamClientContext = CFStreamClientContext()

    var readStream4: CFReadStream?

    var readStream6: CFReadStream?

    var writeStream4: CFWriteStream?

    var writeStream6: CFWriteStream?
    #endif

    var userDataStore: Any?

    public init(delegate: SwiftAsyncUDPSocketDelegate?,
                delegateQueue: DispatchQueue?,
                socketQueue: DispatchQueue?) {
        delegateStore = delegate
        delegateQueueStore = delegateQueue

        if let socketQueue = socketQueue {
            assert(socketQueue != DispatchQueue.global(qos: .utility),
                   SwiftAsyncSocketAssertError.queueLevel.description)
            assert(socketQueue != DispatchQueue.global(qos: .userInitiated),
                   SwiftAsyncSocketAssertError.queueLevel.description)
            assert(socketQueue != DispatchQueue.global(qos: .default),
                   SwiftAsyncSocketAssertError.queueLevel.description)

            self.socketQueue = socketQueue
        } else {
            self.socketQueue = DispatchQueue(label: SwiftAsyncSocketKeys.socketQueueName)
        }
        super.init()

        self.socketQueue.setSpecific(key: queueKey, value: self)

        #if os(iOS)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeGround),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        #endif
    }

    deinit {
        #if os(iOS)
        NotificationCenter.default.removeObserver(self)
        #endif
        #warning ("Next Step Here")
        
    }

    @objc func applicationWillEnterForeGround() {
        socketQueueDo(async: true, {
            self.resumeReceive4Source()
            self.resumeReceive6Source()
        })
    }

    public func socketQueueDo(async: Bool = false, _ doBlock: @escaping () -> Void) {
        if DispatchQueue.getSpecific(key: queueKey) != nil {
            doBlock()
        } else {
            if async {
                socketQueue.async(execute: doBlock)
            } else { socketQueue.sync(execute: doBlock) }
        }
    }
}
