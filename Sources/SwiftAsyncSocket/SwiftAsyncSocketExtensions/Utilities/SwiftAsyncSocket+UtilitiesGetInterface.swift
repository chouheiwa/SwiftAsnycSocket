//
//  SwiftAsyncSocket+UtilitiesGeting.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2018/12/19.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import Foundation

extension SwiftAsyncSocket {
    /// 从interface描述中获取对应的ipv4地址和ipv6接口
    ///
    /// - Parameters:
    ///   - description: 接口描述字符串
    ///   - port: 接口端口
    /// - Returns: (IPV4地址,IPV6地址)
    func getInterfaceAddress(interface description: String, port: UInt16?) -> (Data?, Data?) {
        let componments = description.split(separator: ":")

        var interface: String?

        if componments.count > 0 {
            if let temp = componments.first {
                interface = String(temp)
            }
        }

        var portTotal = port ?? 0

        if componments.count > 1 && portTotal == 0 {
            guard let componmentData = String(componments[1]).data(using: .utf8) else {
                assert(false, "Invid logic")
                fatalError("Invid logic")
            }

            let portL = strtol(componmentData.convert(), nil, 10)

            if portL > 0 && portL <= UINT16_MAX {
                portTotal = UInt16(portL)
            }
        }

        if interface == nil {
            let (sock4, sock6) = sockaddr.getSockData(fromAny: portTotal)

            return (sock4, sock6)
        } else if let interface = interface, (interface == "localhost" || interface == "loopback") {
            let (sock4, sock6) = sockaddr.getSockData(fromLocalHost: portTotal)

            return (sock4, sock6)
        } else {
            return getDataFrom(other: interface, port: portTotal)
        }
    }

    func getInterfaceAddress(url: URL) -> Data? {
        let path = url.path as NSString

        var nativeAddr = sockaddr_un()

        nativeAddr.sun_family = sa_family_t(AF_UNIX)

        let length = MemoryLayout.size(ofValue: nativeAddr.sun_path)

        strlcpy(nativeAddr.sun_path_pointer(), path.fileSystemRepresentation, length + 1)

        return Data(bytes: &nativeAddr, count: MemoryLayout.size(ofValue: nativeAddr))
    }

    private func getDataFrom(other interface: String?, port: UInt16) -> (Data?, Data?) {
        let iface: UnsafePointer<Int8>? = interface?.data(using: .utf8)?.convert()

        var addrs: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&addrs) == 0 else {
            return (nil, nil)
        }
        var cursor = addrs
        var addr4: Data?
        var addr6: Data?
        while cursor != nil {
            if let cursor = cursor {
                getAddr(from: cursor.pointee, addr4: &addr4, addr6: &addr6, iface: iface, port: port)
            }

            cursor = cursor?.pointee.ifa_next
        }
        freeifaddrs(addrs)
        return (addr4, addr6)
    }

    private func getAddr(from cursor: ifaddrs,
                         addr4: inout Data?,
                         addr6: inout Data?,
                         iface: UnsafePointer<Int8>?,
                         port: UInt16) {
        let saFamily = cursor.ifa_addr.pointee.sa_family

        if addr4 == nil && saFamily == AF_INET {
            var nativeAddr4 = cursor.ifa_addr.pointee.copyToSockaddr_in()

            if strcmp(cursor.ifa_name, iface) == 0 {
                // Name match
                nativeAddr4.sin_port = CFSwapInt16HostToBig(port)

                addr4 = Data(bytes: &nativeAddr4, count: MemoryLayout.size(ofValue: nativeAddr4))
            } else {
                var ipAddr: [Int8] = []

                ipAddr.reserveCapacity(Int(INET_ADDRSTRLEN))

                let conversion = inet_ntop(AF_INET,
                                           &(nativeAddr4.sin_addr),
                                           &ipAddr,
                                           socklen_t(ipAddr.capacity))

                if conversion != nil && strcmp(&ipAddr, iface) == 0 {
                    nativeAddr4.sin_port = CFSwapInt16HostToBig(port)
                    addr4 = Data(bytes: &nativeAddr4, count: MemoryLayout.size(ofValue: nativeAddr4))
                }
            }
        } else if addr6 == nil && saFamily == AF_INET6 {
            var nativeAddr6 = cursor.ifa_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, {$0.pointee})

            if strcmp(cursor.ifa_name, iface) == 0 {
                // Name match

                nativeAddr6.sin6_port = CFSwapInt16HostToBig(port)

                addr6 = Data(bytes: &nativeAddr6, count: MemoryLayout.size(ofValue: nativeAddr6))
            } else {
                var ipAddr: [Int8] = []

                ipAddr.reserveCapacity(Int(INET_ADDRSTRLEN))

                let conversion = inet_ntop(AF_INET,
                                           &(nativeAddr6.sin6_addr),
                                           &ipAddr,
                                           socklen_t(ipAddr.capacity))

                if conversion != nil && strcmp(&ipAddr, iface) == 0 {
                    nativeAddr6.sin6_port = CFSwapInt16HostToBig(port)
                    addr6 = Data(bytes: &nativeAddr6, count: MemoryLayout.size(ofValue: nativeAddr6))
                }
            }
        }
    }
}
