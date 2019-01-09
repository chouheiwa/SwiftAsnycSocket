//
//  String.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2018/12/20.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import Foundation

extension String {
    var UTF8String: UnsafePointer<Int8> {
        guard let utf8 = self.data(using: .utf8) else { fatalError("Can not be here") }

        return utf8.convert()
    }
}
