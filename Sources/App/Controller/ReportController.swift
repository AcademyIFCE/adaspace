import Vapor
import Fluent

struct ReportController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("reports") {
            $0.get(":post_id", use: all)
            $0.group(Token.authenticator()) {
                $0.post(":post_id", use: create)
            }
        }
    }
    
    func create(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let id = try req.parameters.require("post_id", as: Post.IDValue.self)
        if let _ = try await Report.query(on: req.db).filter(\.$post.$id == id).filter(\.$user.$id == user.requireID()).first() {
            return Response(status: .conflict)
        } else {
            let reason = try req.content.decode(String.self)
            if try await Post.find(id, on: req.db) != nil {
                let report = try Report(reason: reason, userID: user.requireID(), postID: id)
                try await report.create(on: req.db)
                return Response(status: .created)
            } else {
                throw Abort(.notFound)
            }
        }
    }
    
    func all(req: Request) async throws -> [String] {
        let id = try req.parameters.require("post_id", as: Post.IDValue.self)
        return try await Report.query(on: req.db).filter(\.$post.$id == id).all().map(\.reason)
    }
    
}
