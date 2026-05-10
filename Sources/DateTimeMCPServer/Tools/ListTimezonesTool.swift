import Foundation
import MCP

struct ListTimezonesTool: Sendable {
    static let definition = Tool(
        name: DateTimeTool.listTimezones.rawValue,
        description: "List IANA timezone identifiers with optional filtering and pagination",
        inputSchema: .object([
            "type": "object",
            "properties": [
                "query": ["type": "string"],
                "region": ["type": "string"],
                "limit": ["type": "integer", "minimum": 1, "maximum": 500],
                "cursor": ["type": "string"]
            ]
        ])
    )

    func call(arguments: [String: Value]?) throws -> CallTool.Result {
        let parser = ToolArgumentParser(arguments: arguments)
        let query = try parser.optionalString("query")?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let region = try parser.optionalString("region")?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let limit = try parser.optionalInt("limit") ?? 100
        guard (1...500).contains(limit) else {
            throw MCPError.invalidParams("Argument 'limit' must be between 1 and 500")
        }

        let cursorRaw = try parser.optionalString("cursor") ?? "0"
        guard let cursor = Int(cursorRaw), cursor >= 0 else {
            throw MCPError.invalidParams("Argument 'cursor' must be a non-negative integer encoded as a string")
        }

        let matched = TimeZone.knownTimeZoneIdentifiers.sorted().compactMap { identifier -> [String: Value]? in
            let parts = identifier.split(separator: "/", maxSplits: 1).map(String.init)
            let zoneRegion = parts.first ?? ""
            let cityPart = parts.count > 1 ? parts[1] : parts[0]
            let cityLabel = cityPart.replacingOccurrences(of: "_", with: " ")

            if let region, !zoneRegion.lowercased().hasPrefix(region) {
                return nil
            }

            if !query.isEmpty {
                let haystack = "\(identifier.lowercased()) \(cityLabel.lowercased())"
                if !haystack.contains(query) {
                    return nil
                }
            }

            return [
                "id": .string(identifier),
                "region": .string(zoneRegion),
                "cityLabel": .string(cityLabel)
            ]
        }

        let page = Array(matched.dropFirst(cursor).prefix(limit))
        let nextCursor: Value? = (cursor + page.count) < matched.count ? .string(String(cursor + page.count)) : nil

        return .init(
            content: [.text(text: "Returned \(page.count) timezone(s) out of \(matched.count) matched.", annotations: nil, _meta: nil)],
            structuredContent: .object([
                "items": .array(page.map(Value.object)),
                "totalMatched": .int(matched.count),
                "nextCursor": nextCursor ?? .null
            ]),
            isError: false
        )
    }
}
