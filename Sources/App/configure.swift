import Vapor
import Fluent
import FluentSQLiteDriver
import Foundation

public func configure(_ app: Application) throws {
    
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory + "documentation"))
    
    app.routes.defaultMaxBodySize = "5mb"
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreatePost())
    app.migrations.add(UpdateLike())
    app.migrations.add(CreateToken())
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    try app.autoMigrate().wait()
    
    try routes(app)
}
