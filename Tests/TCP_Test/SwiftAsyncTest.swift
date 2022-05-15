//
//  MacSwiftAsyncTest.swift
//  MacSwiftAsyncSocketTests
//
//  Created by chouheiwa on 2019/1/2.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import XCTest
@testable import SwiftAsyncSocket

enum TestSocketKind {
    case createServerCanAccept
    case createServerCanSendData(_ data: Data)
    case createServerCanReadData(_ data: Data)
    case createServerCanReceiveTerminator(_ dataArray: [Data], finalData: Data)

    case connectionURL(_ url: URL)
    case readDataTimeOut
    case readDataToTerminatorData(_ data: Data)
    case readDataToLength(_ length: Int)

    case noTest
}

enum ConnectionKind {
    case host(_ host:String, port: UInt16)
    case url(_ url: URL)
}

class SwiftAsyncTest: XCTestCase {
    var swiftASyncSocket: SwiftAsyncSocket?

    var testException: XCTestExpectation?

    var testKind: TestSocketKind = .noTest

    var connectionKind: ConnectionKind = .host("127.0.0.1", port: 5553)

    var server: Server?

    override func setUp() {

        swiftASyncSocket = SwiftAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global(), socketQueue: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        swiftASyncSocket?.disconnect()
        self.server = nil
    }

    func createClient(testDescription: String = #function,
                      waitTime: TimeInterval = 5,
                      connectionKind: ConnectionKind,
                      successStep: (() -> Void)? = nil,
                      failtureStep: ((Error) -> Void)? = {XCTAssert(false, "\($0)")}) {
        let testException = XCTestExpectation(description: testDescription)
        self.testException = testException
        self.connectionKind = connectionKind
        do {
            switch connectionKind {
            case .host(let host, let port):
                try swiftASyncSocket?.connect(toHost: host, onPort: port)
            default:
                break
            }
        } catch {
            failtureStep?(error)
            return
        }

        successStep?()

        self.wait(for: [testException], timeout: waitTime)
    }

    func createServer() -> Server {
        let server = Server()
        self.server = server
        return server
    }

    func createServerAndClient(testDescription: String = #function,
                               waitTime: TimeInterval = 5,
                               setupServerDo: ((Server) -> Void)? = nil,
                               successStep: (() -> Void)? = nil,
                               failtureStep: ((Error) -> Void)? = {XCTAssert(false, "\($0)")}) {
        let server = createServer()

        setupServerDo?(server)

        createClient(testDescription: testDescription,
                         waitTime: waitTime,
                         connectionKind: .host("127.0.0.1", port: server.port),
                         successStep: successStep,
                         failtureStep: failtureStep)
    }

    func testServerCanAccept() {
        testKind = .createServerCanAccept
        createServerAndClient()
    }

    func testServerCanSendData() {
        guard let data = "this is a test read data".data(using: .utf8) else {
            XCTAssert(false, "Error in system")
            return
        }
        testKind = .createServerCanSendData(data)

        createServerAndClient(setupServerDo: {
            $0.canSendData = {$0.write(data: data, timeOut: -1, tag: 0)}
        })
    }

    func testServerCanReadData() {
        guard let data = "this is a test read data".data(using: .utf8) else {
            XCTAssert(false, "Error in system")
            return
        }

        testKind = .createServerCanReadData(data)

        createServerAndClient(setupServerDo: {
            $0.canSendData = {
                $0.readData(timeOut: -1, tag: 0)
            }

            $0.didReadData = {
                guard $0 == data else {
                    XCTAssert(false, "Data error")
                    return
                }

                self.testException?.fulfill()
            }
        })
    }

    /// This function will call send data serval times
    func testServerCanReadTerminatorData() {
        let terminatorData = SwiftAsyncSocket.CRLFData

        let stringArray = ["This ",
                           "is ",
                           "a ",
                           "test ",
                           "socket ",
                           "function"]

        var dataArray: [Data] = []

        var finalData: Data = Data()

        for item in stringArray {
            guard let data = item.data(using: .utf8) else {
                XCTAssert(false, "Error in system")
                return
            }

            dataArray.append(data)

            finalData.append(data)
        }

        dataArray.append(terminatorData)
        finalData.append(terminatorData)

        testKind = .createServerCanReceiveTerminator(dataArray, finalData: finalData)

        createServerAndClient(setupServerDo: {
            $0.canSendData = {
                $0.readData(toData: terminatorData, timeOut: -1, tag: 0)
            }

            $0.didReadData = {
                guard $0 == finalData else {
                    XCTAssert(false, "Data error")
                    return
                }

                self.testException?.fulfill()
            }
        })
    }
    /// Here is the question.How do we test url? This function will be tested when I found the way to test url
//    func testConnectToURL() {
//        guard let url = URL(string: "127.0.0.1:5553") else {
//            return
//        }
//
//        createConnection(connectionKind: .url(url))
//    }
}

extension SwiftAsyncTest: SwiftAsyncSocketDelegate {
    func socket(_ socket: SwiftAsyncSocket, didConnect toHost: String, port: UInt16) {
        switch testKind {
        case .createServerCanAccept:
            testException?.fulfill()
        case .createServerCanSendData:
            socket.readData(timeOut: -1, tag: 0)
        case .createServerCanReadData(let data):
            socket.write(data: data, timeOut: -1, tag: 0)
        case .createServerCanReceiveTerminator(let array, _):
            for data in array {
                socket.write(data: data, timeOut: -1, tag: 0)
            }
        case .readDataTimeOut:
            socket.readData(timeOut: -1, tag: 0)
        case .readDataToTerminatorData(let data):
            socket.readData(toData: data, timeOut: -1, tag: 0)
        case .readDataToLength(let length):
            socket.readData(toLength: UInt(length), timeOut: -1, tag: 0)
        case .noTest, .connectionURL:
            break
        }
    }

    func socket(_ socket: SwiftAsyncSocket, didConnect toURL: URL) {
        switch testKind {
        case .connectionURL(let url):
            XCTAssert(url == toURL, "URL is wrong")
            self.testException?.fulfill()
        default:
            break
        }
    }

    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {
    }

    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        switch testKind {
        case .createServerCanSendData(let dataSend):
            guard data == dataSend else {
                XCTAssert(false, "Data was not equal")
                return
            }
            testException?.fulfill()
        default:
            guard let text = String(data: data, encoding: .utf8) else { return }

            print("\(text)")

            self.testException?.fulfill()
        }
    }

    func socket(_ socket: SwiftAsyncSocket, didReadParticalDataOf length: UInt, with tag: Int) {
        print("length:\(length)")
    }
}
