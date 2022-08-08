import Fluent

struct CreateToken: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(Token.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("user_id", .uuid, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("source", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema).delete()
    }
    
}
