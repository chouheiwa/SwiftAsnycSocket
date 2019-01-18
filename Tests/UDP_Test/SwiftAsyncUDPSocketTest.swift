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
    enum TestKind {
        case testConnect
    }

    var socket: SwiftAsyncUDPSocket?
    var testException: XCTestExpectation?

    override func setUp() {
        socket = SwiftAsyncUDPSocket(delegate: self,
                                     delegateQueue: DispatchQueue.global())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let testException = XCTestExpectation(description: "11111111")

        self.testException = testException
        guard let socket = socket else {
            return
        }
        do {
            try socket.connect(to: "lolololo.com", port: 9090)
            socket.send(data: "123".data(using: .utf8) ?? Data(), timeout: 5, tag: 10)
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
        print("\(#function)")
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didNotSendDataWith tag: Int, dueTo error: SwiftAsyncSocketError) {
        print("2222")
    }

    func updSocket(_ socket: SwiftAsyncUDPSocket, didCloseWith error: SwiftAsyncSocketError?) {
        print("\(#function)")
    }
}
