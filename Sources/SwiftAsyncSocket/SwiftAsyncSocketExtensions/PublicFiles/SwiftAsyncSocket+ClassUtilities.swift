//
//  SwiftAsyncSocket+ClassUtilities.swift
//  SwiftAsyncSocket
//
//  Created by chouheiwa on 2018/12/20.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import Foundation

extension SwiftAsyncSocket {
    public enum SocketDataType {
        case IPv4Data(_ data: Data)
        case IPv6Data(_ data: Data)
        case bothData(IPv4: Data, IPv6: Data)

        init(IPv4 ipv4Data: Data?, IPv6 ipv6Data: Data?) throws {
            if let ipv4Data = ipv4Data, let ipv6Data = ipv6Data {
                self = .bothData(IPv4: ipv4Data, IPv6: ipv6Data)
            } else if let ipv4Data = ipv4Data {
                self = .IPv4Data(ipv4Data)
            } else if let ipv6Data = ipv6Data {
                self = .IPv6Data(ipv6Data)
            } else {
                throw SwiftAsyncSocketError.badParamError("Both ipv4 & ipv6 data was nil")
            }
        }
    }

    public class func lookup(host: String, port: UInt16) throws -> SocketDataType {
        guard host != "localhost" && host != "loopback" else {
            let (nativeAddr4, nativeAddr6) = sockaddr.getSockData(fromLocalHost: port)

            return try SocketDataType(IPv4: nativeAddr4, IPv6: nativeAddr6)
        }

        var hints = addrinfo()

        hints.ai_family = PF_UNSPEC
        hints.ai_socktype = SOCK_STREAM
        hints.ai_protocol = IPPROTO_TCP

        var res: UnsafeMutablePointer<addrinfo>?

        var res0: UnsafeMutablePointer<addrinfo>?

        let error = getaddrinfo(host.UTF8String, String(port).UTF8String, &hints, &res0)

        guard error == 0 else {
            throw SwiftAsyncSocketError.gaiError(code: error)
        }
        defer {
            freeaddrinfo(res0)
        }

        var address4: Data?
        var address6: Data?

        res = res0

        while res != nil {
            guard let pointer = res else {
                fatalError("Code can not be here")
            }

            let type = pointer.pointee.ai_family

            let sock: UnsafeMutablePointer<sockaddr> = pointer.pointee.ai_addr

            if type == AF_INET {
                address4 = Data(bytes: sock, count: Int(pointer.pointee.ai_addrlen))
            } else if type == AF_INET6 {
                let sock6 = sock.withMemoryRebound(to: sockaddr_in6.self,
                                                   capacity: 1, {$0})

                if sock6.pointee.sin6_port == 0 {
                    sock6.pointee.sin6_port = CFSwapInt16HostToBig(port)
                }

                address6 = Data(bytes: sock6, count: MemoryLayout.size(ofValue: sock6.pointee))
            }

            res = res?.pointee.ai_next
        }

        guard address4 != nil || address6 != nil else {
            throw SwiftAsyncSocketError.gaiError(code: EAI_FAIL)
        }

        return try SocketDataType(IPv4: address4, IPv6: address6)
    }

    public class var CRLFData: Data {
        var list: [UInt8] = [0x0D, 0x0A]

        return Data(bytes: &list, count: 2)
    }

    public class var CRData: Data {
        var list: [UInt8] = [0x0D]

        return Data(bytes: &list, count: 1)
    }

    public class var LFData: Data {
        var list: [UInt8] = [0x0A]

        return Data(bytes: &list, count: 1)
    }

    public class var zeroData: Data {
        var list: [UInt8] = [0x00]

        return Data(bytes: &list, count: 1)
    }

}
