//
//  Data.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2018/12/18.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import Foundation

extension Data {
    func convert<DataType>(offset: Int = 0) -> UnsafePointer<DataType> {
        return self.withUnsafeBytes { (buffer: UnsafePointer<DataType>) -> UnsafePointer<DataType> in
            return buffer} + offset
    }

    mutating func convertMutable<T>(offset: Int = 0) -> UnsafeMutablePointer<T> {
        return self.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<T> in
            return buffer} + offset
    }
}
