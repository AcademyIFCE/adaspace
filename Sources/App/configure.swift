import Vapor
import Fluent
import FluentSQLiteDriver
import Foundation

final class ReportMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        print(#function, request.url.path)
        return next.respond(to: request)
    }
}

public func configure(_ app: Application) throws {
    
//    app.http.server.configuration.hostname = "0.0.0.0"
    
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.middleware.use(ReportMiddleware())
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory + "documentation"))
    
    app.routes.defaultMaxBodySize = "5mb"
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreatePost())
    app.migrations.add(UpdateLike())
    app.migrations.add(CreateReport())
    app.migrations.add(CreateToken())
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    
    try app.autoMigrate().wait()
    
    try routes(app)
    
}
