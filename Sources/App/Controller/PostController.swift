import Vapor
import Fluent
import SQLiteKit

struct PostController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("posts") {
            $0.get(use: index)
            $0.get(":id", use: show)
            $0.group(Token.authenticator()) {
                $0.post(use: create)
                $0.patch(":id", use: update)
                $0.delete(":id", use: delete)
            }
            $0.get("paginated", use: indexPaginated)
        }
    }
    
    func index(req: Request) async throws -> [Post.Public] {
        let query: QueryBuilder<Post>
        if let userID = req.query[User.IDValue.self, at: "user_id"] {
            query = Post.query(on: req.db).with(\.$user).sort(\.$createdAt, .descending).filter(\.$user.$id == userID)
        } else {
            query = Post.query(on: req.db).with(\.$user).sort(\.$createdAt, .descending)
        }
        return try await query.all().map(\.public)
    }
    
    func show(req: Request) async throws -> Post.Public {
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        if let post = try await Post.find(id, on: req.db) {
            return post.public
        } else {
            throw Abort(.notFound)
        }
    }
    
    func create(req: Request) async throws -> Post.Public {
        let user = try req.auth.require(User.self)
        switch req.headers.contentType {
            case .plainText?:
                let content = try req.content.decode(String.self)
                let post = try Post(content: content, userID: user.requireID())
                try await post.save(on: req.db)
                return post.public
            case .formData?:
                let form = try req.content.decode(Post.Form.self)
            guard let contentType = form.media?.contentType, [.png, .jpeg, .mpeg].contains(contentType) else {
                    throw Abort(.unsupportedMediaType)
                }
                let post = try Post(form: form, userID: user.requireID())
                try await post.save(on: req.db)
                return post.public
            default:
                throw Abort(.badRequest)
        }
    }
    
    func update(req: Request) async throws -> Post {
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        if let post = try await Post.find(id, on: req.db) {
            post.content = try req.content.decode(String.self)
            try await post.update(on: req.db)
            return post
        } else {
            throw Abort(.notFound)
        }
    }
    
    func delete(req: Request) async throws -> Post {
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        if let post = try await Post.find(id, on: req.db) {
            try await post.delete(on: req.db)
            return post
        } else {
            throw Abort(.notFound)
        }
    }
    
    func indexPaginated(req: Request) async throws -> Page<Post.Public> {
        let query: QueryBuilder<Post>
        if let userID = req.query[User.IDValue.self, at: "user_id"] {
            query = Post.query(on: req.db).with(\.$user).sort(\.$createdAt, .descending).filter(\.$user.$id == userID)
        } else {
            query = Post.query(on: req.db).with(\.$user).sort(\.$createdAt, .descending)
        }
        return try await query.paginate(for: req).map(\.public)
    }
    
}
