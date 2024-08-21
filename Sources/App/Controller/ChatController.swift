//
//  File.swift
//  
//
//  Created by Mateus Rodrigues on 07/08/22.
//

import Vapor

class ChatController: RouteCollection {
    
    private var connections = Set<Connection>()
    
    func boot(routes: RoutesBuilder) throws {
        routes.group(Token.authenticator()) {
            $0.webSocket("chat", onUpgrade: onUpgrade)
        }
    }
    
    func onUpgrade(request: Request, socket: WebSocket) {
        do {
            let user = try request.auth.require(User.self)
            let connection = try Connection(userID: user.requireID(), socket: socket)
            connections.insert(connection)
            socket.onText { (ws, text) in
                do {
                    try self.dispatch(text, from: connection)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
            socket.close(promise: nil)
        }
    }
    
    func dispatch(_ text: String, from connection: Connection) throws {
        let message = Message(userID: connection.userID, text: text)
        let data = try JSONEncoder().encode(message)
        connections.forEach {
            $0.socket.send([UInt8](data))
        }
    }
    
}
