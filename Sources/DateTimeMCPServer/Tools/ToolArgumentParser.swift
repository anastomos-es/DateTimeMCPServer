import Foundation
import MCP

struct ToolArgumentParser: Sendable {
    let arguments: [String: Value]

    init(arguments: [String: Value]?) {
        self.arguments = arguments ?? [:]
    }

    func optionalString(_ key: String) throws -> String? {
        guard let value = arguments[key] else { return nil }
        guard let string = value.stringValue else {
            throw MCPError.invalidParams("Argument '\(key)' must be a string")
        }
        return string
    }

    func requiredString(_ key: String) throws -> String {
        guard let value = try optionalString(key)?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            throw MCPError.invalidParams("Argument '\(key)' is required")
        }
        return value
    }

    func optionalInt(_ key: String) throws -> Int? {
        guard let value = arguments[key] else { return nil }
        if let int = value.intValue { return int }
        throw MCPError.invalidParams("Argument '\(key)' must be an integer")
    }
}
