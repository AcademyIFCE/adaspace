import Fluent

struct CreatePost: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(Post.schema)
            .id()
            .field("content", .string)
            .field("media", .string)
            .field("like_count", .int)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("user_id", .uuid)
            .foreignKey("user_id", references: User.schema, "id", onDelete: .cascade, onUpdate: .cascade)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Post.schema).delete()
    }
    
}

