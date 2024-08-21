import Vapor
import Fluent

final class Post: Model {
    
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "media")
    var media: String?
    
    @Field(key: "like_count")
    var likeCount: Int
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(text: String, media: String? = nil, userID: User.IDValue) {
        self.text = text
        self.media = media
        self.likeCount = 0
        self.$user.id = userID
    }
    
    init(form: Form, userID: User.IDValue) {
        self.text = form.text
        if let media = form.media {
            self.media = try? media.data.write(to: URL(fileURLWithPath: DirectoryConfiguration.detect().publicDirectory), contentType: media.contentType)
        }
        self.likeCount = 0
        self.$user.id = userID
    }
    
    var `public`: Public {
        Public(id: id!, text: text, media: media, likeCount: likeCount, createdAt: createdAt, updatedAt: updatedAt, userID: $user.id, user: $user.value?.public)
    }
    
}

extension Post: Content { }

extension Post {
    
    struct Form: Content {
        var text: String
        var media: File?
    }
    
    struct Public: Content {
        var id: UUID
        var text: String
        var media: String?
        var likeCount: Int
        var createdAt: Date?
        var updatedAt: Date?
        var userID: UUID
        var user: User.Public?
    }

}

extension ByteBuffer {
    
    func write(to directory: URL, contentType: HTTPMediaType?) throws -> String {
        var buffer = self
        guard let file = buffer.readData(length: buffer.readableBytes) else {
            throw Abort(.internalServerError)
        }
        let filename = SHA256.hash(data: Data(UUID().uuidString.utf8)).hexEncodedString().prefix(30)
        let fileExtension = contentType?.description.components(separatedBy: "/").last ?? ""
        let path = "media/" + filename + "." + fileExtension
        let url = directory.appendingPathComponent(path)
        try file.write(to: url)
        return path
    }
    
}

extension Post {
    
    final class Mock: Model {
        
        struct Input: Content {
            let text: String
            let media: File?
            let createdAt: Date
        }
        
        static let schema = "posts"
        
        @ID(key: .id)
        var id: UUID?
        
        @Field(key: "text")
        var text: String
        
        @Field(key: "media")
        var media: String?
        
        @Field(key: "like_count")
        var likeCount: Int
        
        @Parent(key: "user_id")
        var user: User
        
        @Field(key: "created_at")
        var createdAt: Date?
        
        init() {}
        
        init(text: String, media: String? = nil, userID: User.IDValue, createdAt: Date) {
            self.text = text
            self.media = media
            self.createdAt = createdAt
            self.likeCount = 0
            self.$user.id = userID
        }
        
        var `public`: Post.Public {
            Post.Public(id: id!, text: text, media: media, likeCount: likeCount, createdAt: createdAt, updatedAt: nil, userID: $user.id)
        }
        
    }
    
    
}
