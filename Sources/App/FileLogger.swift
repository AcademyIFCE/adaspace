//
//  File.swift
//  
//
//  Created by Mateus Rodrigues on 07/08/22.
//

import Vapor

public class FileLogger: LogHandler {
    
    public let label: String

    public var logLevel: Logger.Level

    private var queue: DispatchQueue
    private var fileHandle: FileHandle!

    public init(label: String, filePath: String, level: Logger.Level = .debug) {
        self.label = label
        self.logLevel = level
        self.queue = DispatchQueue(label: "FileLoggerQueue", qos: .background)
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        self.fileHandle = FileHandle(forUpdatingAtPath: filePath)
        self.fileHandle.seekToEndOfFile()
    }

    public func close() {
        guard self.fileHandle != nil else {
            return
        }
        
        self.queue.sync {
            self.fileHandle!.closeFile()
            self.fileHandle = nil
        }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        
        var text = ""
        
        if self.logLevel <= .trace {
            text += "[ \(self.label) ] "
        }
            
        text += "[ \(level.name) ]"
            + " "
            + message.description

        let allMetadata = (metadata ?? [:]).merging(self.metadata) { (a, _) in a }

        if !allMetadata.isEmpty {
            text += " " + allMetadata.sortedDescriptionWithoutQuotes
        }

        if self.logLevel <= .debug {
            // log the concise path + line
            let fileInfo = self.conciseSourcePath(file) + ":" + line.description
            text += " (" + fileInfo + ")"
        }
        
        text += "\n"

        self.queue.async {
            if let data = text.data(using: .utf8) {
                self.fileHandle?.seekToEndOfFile()
                self.fileHandle?.write(data)
            }
        }
    }

    public subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get {
            return nil
        }
        set { }
    }

    public var metadata: Logger.Metadata = Logger.Metadata()
    
    private func conciseSourcePath(_ path: String) -> String {
        let separator: Substring = path.contains("Sources") ? "Sources" : "Tests"
        return path.split(separator: "/")
            .split(separator: separator)
            .last?
            .joined(separator: "/") ?? path
    }
    
}

private extension Logger.Metadata {
    var sortedDescriptionWithoutQuotes: String {
        let contents = Array(self)
            .sorted(by: { $0.0 < $1.0 })
            .map { "\($0.description): \($1)" }
            .joined(separator: ", ")
        return "[\(contents)]"
    }
}
