import Vapor
import Fluent

struct UserController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("users") {
            $0.get(use: index)
            $0.get(":id", use: show)
            $0.post(use: create)
            $0.group(Token.authenticator()) {
                $0.get("me", use: current)
                $0.put("avatar", use: updateAvatar)
                $0.delete("avatar", use: deleteAvatar)
                $0.post("logout", use: logout)
            }
            $0.grouped(User.authenticator()).post("login", use: login)
            
            $0.post("mock", use: mock_create)
        }
    }
    
    func index(req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map(\.public)
    }
    
    func show(req: Request) async throws -> User.Public {
        let id = try req.parameters.require("id", as: User.IDValue.self)
        if let user = try await User.find(id, on: req.db) {
            return user.public
        } else {
            throw Abort(.notFound)
        }
    }
    
    func create(req: Request) async throws -> Session {
        let input = try req.content.decode(User.Input.self)
        let user = try User(input)
        try await user.save(on: req.db)
        let token = try user.token(source: .signup)
        try await token.save(on: req.db)
        let session = Session(token: token.value, user: user.public)
        return session
    }
    
    func mock_create(req: Request) async throws -> Response {
        let input = try req.content.decode([User.Input].self)
        let users = try input.map({ try User($0) })
        for user in users {
            try await user.save(on: req.db)
        }
        return Response(status: .created)
    }
    
    func current(req: Request) throws -> User.Public {
        let user = try req.auth.require(User.self)
        return user.public
    }
    
    func updateAvatar(req: Request) async throws -> User.Public {
        guard [.png, .jpeg].contains(req.headers.contentType) else {
            throw Abort(.unsupportedMediaType)
        }
        let user = try req.auth.require(User.self)
        guard let data = req.body.data else {
            throw Abort(.badRequest)
        }
        let avatar = try data.write(to: URL(fileURLWithPath: DirectoryConfiguration.detect().publicDirectory), contentType: req.headers.contentType)
        user.avatar = avatar
        try await user.save(on: req.db)
        return user.public
    }
    
    func deleteAvatar(req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        user.avatar = nil
        try await user.save(on: req.db)
        return user.public
    }
    
    func logout(req: Request) async throws -> Session {
        let user = try req.auth.require(User.self)
        guard let token = try await Token.query(on: req.db).filter(\.$user.$id == user.id!).first() else {
            throw Abort(.notFound)
        }
        try await token.delete(on: req.db)
        let session = Session(token: token.value, user: user.public)
        return session
    }
    
    func login(req: Request) async throws -> Session {
        let user = try req.auth.require(User.self)
        let token = try user.token(source: .login)
        try await token.save(on: req.db)
        let session = Session(token: token.value, user: user.public)
        return session
    }
    
}
