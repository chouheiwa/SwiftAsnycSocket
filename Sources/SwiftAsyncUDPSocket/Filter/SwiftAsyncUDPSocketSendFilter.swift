//
//  SwiftAsyncUDPSocketSendFilter.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/11.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation
public struct SwiftAsyncUDPSocketSendFilter: SwiftAsyncUDPSocketFilter {
    public typealias BlockType = (Data, Data, Int) -> Bool

    public var filterBlock: BlockType

    public var queue: DispatchQueue

    public var async: Bool

    public init(filterBlock: @escaping BlockType, queue: DispatchQueue, async: Bool) {
        self.filterBlock = filterBlock
        self.queue = queue
        self.async = async
    }
}
