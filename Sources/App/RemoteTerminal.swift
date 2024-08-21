//
//  File.swift
//  
//
//  Created by Mateus on 04/08/22.
//

import Vapor

//public class RemoteTerminal: Console {
//        
//    public static var `default` = RemoteTerminal()
//    
//    private var sockets: [WebSocket] = []
//    
//    public var size: (width: Int, height: Int) = (0, 0)
//    
//    public var userInfo: [AnyHashable : Any] = [:]
//    
//    public init() { }
//    
//    public func connect(_ socket: WebSocket) {
//        sockets.append(socket)
//    }
//    
//    public func input(isSecure: Bool) -> String {
//        fatalError("input(isSecure:) not implemented")
//    }
//    
//    public func output(_ text: ConsoleText, newLine: Bool) {
//        let data = "\(text)".data(using: .utf8)!
//        sockets.forEach {
//            $0.send([UInt8](data))
//        }
//    }
//    
//    public func clear(_ type: ConsoleClear) { }
//    
//    public func report(error: String, newLine: Bool) { }
//    
//}
