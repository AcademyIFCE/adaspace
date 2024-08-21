import Vapor
import Fluent

struct LikeController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("likes") {
            $0.get("liking_users", ":post_id", use: likingUsers)
            $0.get("liked_posts", ":user_id", use: likedPosts)
            $0.grouped(Token.authenticator()).post(use: like)
            $0.grouped(Token.authenticator()).delete(":post_id", use: unlike)
            $0.get("mock", ":count", use: mock_like)
        }
    }
    
    func like(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let postID = try req.content.decode(UUID.self)
        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound)
        }
        if let _ = try await Like.query(on: req.db).filter(\.$post.$id == postID).filter(\.$user.$id == userID).first() {
            return Response(status: .conflict)
        } else {
            
            let like = try Like(userID: user.requireID(), postID: post.requireID())
            
            post.likeCount += 1
            
            try await req.db.transaction {
                try await like.save(on: $0)
                try await post.save(on: $0)
            }
            
            return Response(status: .noContent)
        }
    }
    
    func mock_like(req: Request) async throws -> Response {
        
        guard let count = req.parameters.get("count", as: Int.self) else {
            throw Abort(.badRequest)
        }
                
        let users = try await User.query(on: req.db).all()
        
        guard !users.isEmpty else {
            throw Abort(.internalServerError)
        }
        
        let posts = try await Post.query(on: req.db).all()
        
        guard !posts.isEmpty else {
            throw Abort(.internalServerError)
        }
                
        for _ in (0..<count) {
            
            let post = posts.randomElement()!
            let user = users.filter({ $0.id != post.$user.id }).randomElement()!
            
            let postID = try post.requireID()
            let userID = try user.requireID()
            
            if let _ = try await Like.query(on: req.db).filter(\.$post.$id == postID).filter(\.$user.$id == userID).first() {
                continue
            }
            
            let like = try Like(userID: user.requireID(), postID: post.requireID())
            
            post.likeCount += 1

            try await req.db.transaction {
                try await like.save(on: $0)
                try await post.save(on: $0)
            }
            
        }
                
        return Response(status: .created)
        
    }
    
    func unlike(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        guard let postID = req.parameters.get("post_id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound)
        }
        guard let like = try await Like.query(on: req.db).filter(\.$post.$id == postID).filter(\.$user.$id == userID).first() else {
            throw Abort(.notFound)
        }
        post.likeCount -= 1
        try await req.db.transaction {
            try await like.delete(on: $0)
            try await post.save(on: $0)
        }
        return Response(status: .noContent)
    }
    
    func likingUsers(req: Request) async throws -> [User.Public] {
        guard let postID = req.parameters.get("post_id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let likes = try await Like.query(on: req.db).filter(\.$post.$id == postID).with(\.$user).all()
        return likes.map(\.user.public)
    }
    
    func likedPosts(req: Request) async throws -> [Post.Public] {
        guard let userID = req.parameters.get("user_id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let likes = try await Like.query(on: req.db).filter(\.$user.$id == userID).with(\.$post).all()
        return likes.map(\.post.public)
    }

}
