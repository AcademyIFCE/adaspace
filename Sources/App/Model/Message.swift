import Foundation

struct Message: Codable {
    let userID: User.IDValue
    let text: String
}
