import Vapor
import Fluent

final class Like: Model {
    
    static let schema = "likes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "post_id")
    var post: Post
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(userID: User.IDValue, postID: Post.IDValue) {
        self.$user.id = userID
        self.$post.id = postID
    }
    
}

extension Like: Content { }

extension Like {
    
    struct Input: Content {
        
        let postID: Post.IDValue
        
        enum CodingKeys: String, CodingKey {
            case postID = "post_id"
        }

    }
    
}
