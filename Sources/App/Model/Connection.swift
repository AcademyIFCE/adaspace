import Vapor

final class Connection: Hashable {
    
    let id = UUID()
    let userID: User.IDValue
    let socket: WebSocket
    
    init(userID: User.IDValue, socket: WebSocket) {
        self.userID = userID
        self.socket = socket
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }
    
}
