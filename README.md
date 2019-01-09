## SwiftAsyncSocket
SwiftAsyncSocket is a socket connnection tool based on GCD with full implement by **Swift**. 

I translated it from [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).

In other words, if you have experience to use **CocoaAsyncSocket**, you will feel familar to this.

Now **SwiftAsyncSocket** only support TCP/IP socket. I will continue to improve the functionality to support UDP.

**SwiftAsyncSocket** is heavier then **CocoaAsyncSocket**. Because there is more then 8,000 line in one file of **CocoaAsyncSocket**. I scattered these logic across multiple files.

**SwiftAsyncSocket** has already passed **SwiftLint** check.

## Installation
**SwiftAsyncSocket** will soon support **Cocoapods**

So now you can only use this by those steps.

```
# Download the source of the code 
git clone https://github.com/chouheiwa/SwiftAsnycSocket.git

cd SwiftAsnycSocket

pod install
```

Then open workspace file. And use `cmd + b` to build a framework. Finally copy it to your work.

## Usage
#### TCP/IP
##### 1. Use as client. 

If there has a socket server start at localhost:8080
```Swift
import SwiftAsyncSocket

class Client {
    var socket: SwiftAsyncSocket
    
    init() {
        // you can not set delegate here because in this line that init function has not complete.So set delegate next line
        socket = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil)
        // All the delagate function is optional. If you want to use. You can implement it.
        socket.delgate = self
        
        do {
            // Connected 
            try socket.connect(toHost: "localhost", onPort: 8080)
        } catch {
            // Here to print error
            print("\(error)")
        }
    }
}
/// If you want to use as client, 
/// at least you need to implement these three method
extension Client: SwiftAsyncSocketDelgate {
    func socket(_ socket: SwiftAsyncSocket, didConnect toHost: String, port: UInt16) {
        // If you use socket.connect(toHost: , onPort: )
        // When the socket connected, this method will be called
        // Then you can call 
        // socket.write(data:, timeOut:, tag:) 
        // to send the data to server or 
        // socket.readData(timeOut:, tag:)
        // to read data from server
        
    }
    
    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {
        // When send data complete, this method will be called
    }

    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        // When read data complete, this method will return the data from server
    }
}

```
##### 2. Use as server.
```Swift
import Foundation
import SwiftAsyncSocket
class Server: SwiftAsyncSocketDelegate {
    var baseSocket: SwiftAsyncSocket
    /// Here we use map to help we locate which socket has already been disconnected
    var acceptSockets: [String:SwiftAsyncSocket] = [:]

    var port: UInt16

    var canAccept: Bool = false

    var canSendData: ((SwiftAsyncSocket) -> Void)?

    var didReadData: ((Data) -> Void)?

    init() {
        baseSocket = SwiftAsyncSocket(delegate: nil, delegateQueue: DispatchQueue.global(), socketQueue: nil)

        port = UInt16.random(in: 1024..<50000)

        baseSocket.delegate = self

        do {
            canAccept = try baseSocket.accept(port: port)

            canAccept = true
        } catch let error as SwiftAsyncSocketError {
            print("\(error)")
        } catch {
            fatalError("\(error)")
        }
    }

    func socket(_ socket: SwiftAsyncSocket, didAccept newSocket: SwiftAsyncSocket) {
        /// We use a time and a random number to make key unique
        let random = Int.random(in: 0..<99999)

        let date = Date()
        let key = "\(date)\(random)"
        acceptSockets[key] = newSocket
        newSocket.userData = key
        newSocket.delegate = self
        newSocket.delegateQueue = DispatchQueue.global()
        canSendData?(newSocket)
    }

    func socket(_ socket: SwiftAsyncSocket, didWriteDataWith tag: Int) {

    }

    func socket(_ socket: SwiftAsyncSocket, didRead data: Data, with tag: Int) {
        didReadData?(data)
    }

    func socket(_ socket: SwiftAsyncSocket?, didDisconnectWith error: SwiftAsyncSocketError?) {
        guard let key = socket?.userData as? String else { return }

        acceptSockets.removeValue(forKey: key)
    }
}
```

#### UDP

Comming soon