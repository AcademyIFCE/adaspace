import Vapor

struct Session: Content {
    let token: String
    let user: User.Public
}
