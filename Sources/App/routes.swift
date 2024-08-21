import Vapor

func routes(_ app: Application) throws {
    
    app.routes.get { req -> String in
        let routes = req.application.routes.all
        return routes.map(\.description).joined(separator: "\n")
    }
    
    app.routes.get("documentation") { req in
        req.view.render(app.directory.publicDirectory + "documentation/index.html")
    }
    
//    app.routes.get("logs") { req in
//        let logs = try String(contentsOf: URL(fileURLWithPath: app.directory.publicDirectory + "logs.txt"), encoding: .utf8)
//        return logs
//    }
  
//    app.webSocket("terminal") { req, socket in
//        RemoteTerminal.default.connect(socket)
//    }
    
    try app.register(collection: UserController())
    try app.register(collection: PostController()) 
    try app.register(collection: LikeController())
    try app.register(collection: ReportController())
    try app.register(collection: ChatController())
    
}
