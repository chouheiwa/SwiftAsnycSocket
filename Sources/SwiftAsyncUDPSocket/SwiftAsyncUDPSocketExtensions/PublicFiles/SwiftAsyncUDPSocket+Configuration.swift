//
//  SwiftAsyncUDPSocket+OtherVars.swift
//  SwiftAsyncSocket
//
//  Created by Di on 2019/1/11.
//  Copyright © 2019 chouheiwa. All rights reserved.
//

import Foundation

extension SwiftAsyncUDPSocket {
    public weak var delegate: SwiftAsyncUDPSocketDelegate? {
        get {
            var delegate: SwiftAsyncUDPSocketDelegate?
            socketQueueDo {
                delegate = self.delegateStore
            }
            return delegate
        }

        set {
            socketQueueDo(async: false, {
                self.delegateStore = newValue
            })
        }
    }

    public var delegateQueue: DispatchQueue? {
        get {
            var delegate: DispatchQueue?
            socketQueueDo {
                delegate = self.delegateQueueStore
            }
            return delegate
        }

        set {
            socketQueueDo(async: false, {
                self.delegateQueueStore = newValue
            })
        }
    }

    public var isIPv4Enable: Bool {
        get {
            var result = false

            socketQueueDo {
                result = !self.config.contains(.IPv4Disabled)
            }
            return result
        }

        set {
            socketQueueDo(async: false) {
                if newValue {
                    self.config.remove(.IPv4Disabled)
                } else {
                    self.config.insert(.IPv4Disabled)
                }
            }
        }
    }

    public var isIPv6Enable: Bool {
        get {
            var result = false

            socketQueueDo {
                result = !self.config.contains(.IPv6Disabled)
            }
            return result
        }

        set {
            socketQueueDo(async: false) {
                if newValue {
                    self.config.remove(.IPv6Disabled)
                } else {
                    self.config.insert(.IPv6Disabled)
                }
            }
        }
    }

    public var isIPv4Preferred: Bool {
        get {
            var result = false

            socketQueueDo {
                result = self.config.contains(.preferIPv4)
            }
            return result
        }

        set {
            socketQueueDo(async: false) {
                if newValue {
                    self.config.insert(.preferIPv4)
                } else {
                    self.config.remove(.preferIPv4)
                }
            }
        }
    }

    public var isIPv6Preferred: Bool {
        get {
            var result = false

            socketQueueDo {
                result = self.config.contains(.preferIPv6)
            }
            return result
        }

        set {
            socketQueueDo(async: false) {
                if newValue {
                    self.config.insert(.preferIPv6)
                } else {
                    self.config.remove(.preferIPv6)
                }
            }
        }
    }

    public var isIPVersionNeutral: Bool {
        get {
            var result = false

            socketQueueDo {
                result = self.config.contains([.preferIPv4, .preferIPv6]) ||
                    (!self.config.contains(.preferIPv4) && !self.config.contains(.preferIPv6))
            }
            return result
        }

        set {
            guard newValue else {
                assert(false, "IPVersion Neutral can only set to true")
                return
            }

            socketQueueDo(async: false, {
                self.config.insert([.preferIPv4, .preferIPv6])
            })
        }
    }

    public var maxReceiveIPv4BufferSize: UInt16 {
        get {
            var result: UInt16 = 0

            socketQueueDo {
                result = self.max4ReceiveSizeStore
            }
            return result
        }
        set {
            socketQueueDo(async: false, {
                self.max4ReceiveSizeStore = newValue
            })
        }
    }

    public var maxReceiveIPv6BufferSize: UInt32 {
        get {
            var result: UInt32 = 0

            socketQueueDo {
                result = self.max6ReceiveSizeStore
            }
            return result
        }
        set {
            socketQueueDo(async: false, {
                self.max6ReceiveSizeStore = newValue
            })
        }
    }

    public var maxSendBufferSize: UInt16 {
        get {
            var result: UInt16 = 0

            socketQueueDo {
                result = self.maxSendSizeStore
            }
            return result
        }
        set {
            socketQueueDo(async: false, {
                self.maxSendSizeStore = newValue
            })
        }
    }

    public var userData: Any? {
        get {
            var result: Any?

            socketQueueDo {
                result = self.userDataStore
            }
            return result
        }
        set {
            socketQueueDo(async: false, {
                self.userDataStore = newValue
            })
        }
    }
}
