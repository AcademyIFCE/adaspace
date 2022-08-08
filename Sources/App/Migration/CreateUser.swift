import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(User.schema)
            .id()
            .field("name", .string)
            .field("email", .string)
            .field("avatar", .string)
            .unique(on: "email")
            .field("password", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
    
}
