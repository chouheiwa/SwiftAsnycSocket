//
//  SwiftAsyncSocketReadPacketTest.swift
//  SwiftAsyncSocketTests
//
//  Created by chouheiwa on 2018/12/6.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import XCTest
import SwiftAsyncSocket

class SwitAsyncReadPacketTest: XCTestCase {

    var readPacket: SwiftAsyncReadPacket!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let terminatorData: [UInt8] = [0x0D, 0x0A]

        readPacket = SwiftAsyncReadPacket(buffer: nil, terminatorData: Data(terminatorData), tag: 0)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchTerminator() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let terminatorData = readPacket.terminatorData else {XCTAssert(false, "TerminatorData is nil");return}

        XCTAssert(terminatorData.count == 2, "Data count is not 2")

        let appendData: Data = "a".data(using: .utf8)!

        let targetData: Data = Data([0x0D, 0x0A])

        var startTime = arc4random() % 100

        let endTime = arc4random() % 100

        let capcity = startTime + endTime + 2

        while startTime > 0 {
            readPacket.buffer.append(appendData)

            startTime -= 1
        }

        readPacket.buffer.append(targetData)

        for _ in 0..<endTime {
            readPacket.buffer.append(appendData)
        }

        XCTAssert(readPacket.buffer.count == Int(capcity), "Buffer length doesn't right")

        XCTAssert(readPacket.searchForTerminator(afterPrebuffering: Int(capcity)) == Int(endTime),
                  "searchForTerminator not right")
    }

    func testEnsureCapacity() {
        readPacket.ensureCapacity(for: 100)

        XCTAssert(readPacket.buffer.count == 100, "ensureCapacity wrong")

        readPacket.ensureCapacity(for: 50)

        XCTAssert(readPacket.buffer.count == 100, "ensureCapacity wrong")
    }

}
