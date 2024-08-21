import Vapor
import Fluent

final class Report: Model {
    
    static let schema = "reports"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "reason")
    var reason: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "post_id")
    var post: Post
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(reason: String, userID: User.IDValue, postID: Post.IDValue) {
        self.reason = reason
        self.$user.id = userID
        self.$post.id = postID
    }
    
}


//extension Report {
//    
//    struct Public: Content {
//        var id: UUID
//        var reason: String
//    }
//    
//    var `public`: Public {
//        Public(id: id!, reason: reason)
//    }
//
//}
