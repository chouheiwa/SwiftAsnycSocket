//
//  SwiftAsyncUDPSocket+CFStream.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/15.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
#if os(iOS)
extension SwiftAsyncUDPSocket {
    func removeStreamsFromRunloop() {
        if flags.contains(.addedStreamListener) {
            guard let thread = SwiftAsyncThread.default.thread else {
                return
            }
            SwiftAsyncThread.default.perform(#selector(SwiftAsyncThread.default
                .unscheduleCFStreams(asyncUDPSocket:)),
                                             on: thread,
                                             with: nil,
                                             waitUntilDone: true)

            flags.remove(.addedStreamListener)
        }
    }

    func closeReadAndWriteStreams() {
        let closeReadStream: (CFReadStream) -> Void = {
            CFReadStreamSetClient($0, 0, nil, nil)
            CFReadStreamClose($0)
        }

        let closeWriteStream: (CFWriteStream) -> Void = {
            CFWriteStreamSetClient($0, 0, nil, nil)
            CFWriteStreamClose($0)
        }

        if let readStream = readStream4 {
            closeReadStream(readStream)
            self.readStream4 = nil
        }

        if let readStream = readStream6 {
            closeReadStream(readStream)
            self.readStream6 = nil
        }

        if let writeStream = writeStream4 {
            closeWriteStream(writeStream)
            self.writeStream4 = nil
        }

        if let writeStream = writeStream6 {
            closeWriteStream(writeStream)
            self.writeStream6 = nil
        }
    }
}
#endif
