//
//  SwiftAsyncUDPSocketTest.swift
//  SwiftAsyncSocketTests iOS
//
//  Created by chouheiwa on 2019/1/18.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import XCTest
import SwiftAsyncSocket
class SwiftAsyncUDPSocketTest: XCTestCase {
    enum Kind {
        case testConnectAndSend
        case testReceiveData
    }

    var kind: Kind?

    var server: UdpServer!

    var socket: SwiftAsyncUDPSocket!
    var testException: XCTestExpectation?

    override func setUp() {
        socket = SwiftAsyncUDPSocket(delegate: self,
                                     delegateQueue: DispatchQueue.global())
        do {
            server = try UdpServer(port: 33255)
        } catch {
            XCTAssert(false, "\(error)")
        }
    }

    override func tearDown() {
    }

    func testReceiveData() {
        kind = .testReceiveData
        let testException = XCTestExpectation(description: "11111111")

        self.testException = testException

        let data = "data".data(using: .utf8) ?? Data()

        server.didReceiveData = {
            XCTAssert($0 == data, "Data was not equal")
            testException.fulfill()
        }

        do {
            try socket.connect(to: "127.0.0.1", port: 33255)
            socket.send(data: data, timeout: -1, tag: 10)
        } catch {
            XCTAssert(false, "\(error)")
        }

        self.wait(for: [testException], timeout: 50)
    }

    func testConnect() {
        kind = .testConnectAndSend
        let testException = XCTestExpectation(description: "11111111")

        self.testException = testException
        do {
            try socket.connect(to: "127.0.0.1", port: 33255)
            socket.send(data: "123".data(using: .utf8) ?? Data(), timeout: -1, tag: 10)
        } catch {
            XCTAssert(false, "\(error)")
        }

        self.wait(for: [testException], timeout: 50)
    }
}

extension SwiftAsyncUDPSocketTest: SwiftAsyncUDPSocketDelegate {
    func updSocket(_ socket: SwiftAsyncUDPSocket, didConnectTo address: SwiftAsyncUDPSocketAddress) {
        print("\(#function)")
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didNotConnect error: SwiftAsyncSocketError) {
        print("\(#function)")
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didSendDataWith tag: Int) {
        switch kind {
        case .testConnectAndSend?:
            testException?.fulfill()
        default:
            break
        }
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didNotSendDataWith tag: Int, dueTo error: SwiftAsyncSocketError) {
        print("\(error)")
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didCloseWith error: SwiftAsyncSocketError?) {
        print("\(#function)")
    }
}
