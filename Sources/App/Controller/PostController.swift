import Vapor
import Fluent
import SQLiteKit

struct PostController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("posts") {
            $0.get(use: index)
            $0.get(":id", use: show)
            $0.get("comments", ":id", use: getComments)
            $0.group(Token.authenticator()) {
                $0.post(use: create)
                $0.patch(":id", use: update)
                $0.delete(":id", use: delete)
                $0.post("comments", ":id", use: createComment)
            }
            $0.get("paginated", use: indexPaginated)
            $0.post("mock", use: mock_create)
        }
    }
    
    func getComments(req: Request) async throws -> [Post.Public] {
        var query = Post.query(on: req.db).sort(\.$createdAt, .descending)
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        if req.query[String.self, at: "expand"] == "user_id" {
            query = query.with(\.$user)
        }
        query.filter(\.$parent.$id == id)
        return try await query.all().map(\.public)
    }
    
    
    
    func createComment(req: Request) async throws -> Post.Public {
        let user = try req.auth.require(User.self)
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        switch req.headers.contentType {
            case .plainText?:
                let content = try req.content.decode(String.self)
                let post = try Post(text: content, userID: user.requireID(), parentID: id)
                try await post.save(on: req.db)
                return post.public
            case .formData?:
                let form = try req.content.decode(Post.Form.self)
                guard let contentType = form.media?.contentType, [.any].contains(contentType) else {
                    throw Abort(.unsupportedMediaType)
                }
                let post = try Post(form: form, userID: user.requireID(), parentID: id)
                try await post.save(on: req.db)
                return post.public
            default:
                throw Abort(.badRequest)
        }
    }
    
    func index(req: Request) async throws -> [Post.Public] {
        var query = Post.query(on: req.db).sort(\.$createdAt, .descending)
        if req.query[String.self, at: "expand"] == "user_id" {
            query = query.with(\.$user)
        }
        if let userID = req.query[User.IDValue.self, at: "user_id"] {
            query = query.filter(\.$user.$id == userID)
        }
        query.filter(\.$parent.$id == nil)
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
                let post = try Post(text: content, userID: user.requireID())
                try await post.save(on: req.db)
                return post.public
            case .formData?:
                let form = try req.content.decode(Post.Form.self)
                guard let contentType = form.media?.contentType, [.any].contains(contentType) else {
                    throw Abort(.unsupportedMediaType)
                }
                let post = try Post(form: form, userID: user.requireID())
                try await post.save(on: req.db)
                return post.public
            default:
                throw Abort(.badRequest)
        }
    }
    
    func mock_create(req: Request) async throws -> Response {
        
        let inputs = try req.content.decode([Post.Mock.Input].self)
        
        let users = try await User.query(on: req.db).all()
        
        guard !users.isEmpty else {
            throw Abort(.internalServerError)
        }
        
        for input in inputs {
            let post = try Post.Mock(text: input.text, userID: users.randomElement()!.requireID(), createdAt: input.createdAt)
            try await post.save(on: req.db)
        }
        
        return Response(status: .created)
        
    }
    
    func update(req: Request) async throws -> Post {
        let id = try req.parameters.require("id", as: Post.IDValue.self)
        if let post = try await Post.find(id, on: req.db) {
            post.text = try req.content.decode(String.self)
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
