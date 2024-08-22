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

    @Field(key: "reaction")
    var reaction: String?

    init() { }
    
    init(userID: User.IDValue, postID: Post.IDValue, reaction: String?) {
        self.$user.id = userID
        self.$post.id = postID
        self.reaction = reaction
    }

    var `public`: Public {
        Public(
            id: id!,
            reaction: reaction,
            postID: $post.id,
            userID: $user.id,
            user: $user.value?.public
        )
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

    struct Public: Content {
        var id: UUID
        var reaction: String?
        var postID: UUID
        var userID: UUID
        var user: User.Public?
        var createdAt: Date?
    }

}
