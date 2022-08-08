import Fluent

struct UpdateLike: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(Like.schema)
            .id()
            .field("user_id", .uuid)
            .field("post_id", .uuid)
            .field("created_at", .datetime)
            .foreignKey("user_id", references: User.schema, "id", onDelete: .cascade, onUpdate: .cascade)
            .foreignKey("post_id", references: Post.schema, "id", onDelete: .cascade, onUpdate: .cascade)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Like.schema).delete()
    }
    
}
