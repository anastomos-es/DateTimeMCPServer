import Foundation
import MCP

struct LookupTimezoneByCityTool: Sendable {
    static let definition = Tool(
        name: DateTimeTool.lookupTimezoneByCity.rawValue,
        description: "Resolve timezone identifiers from city names",
        inputSchema: .object([
            "type": "object",
            "properties": [
                "city": ["type": "string"],
                "countryCode": ["type": "string"],
                "limit": ["type": "integer", "minimum": 1, "maximum": 20]
            ],
            "required": ["city"]
        ])
    )

    func call(arguments: [String: Value]?) throws -> CallTool.Result {
        let parser = ToolArgumentParser(arguments: arguments)
        let city = try parser.requiredString("city")
        let normalizedCity = Self.normalize(city)
        let countryCode = try parser.optionalString("countryCode")?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let limit = try parser.optionalInt("limit") ?? 5

        guard (1...20).contains(limit) else {
            throw MCPError.invalidParams("Argument 'limit' must be between 1 and 20")
        }

        let matches = TimeZone.knownTimeZoneIdentifiers.compactMap { identifier -> (score: Int, payload: [String: Value])? in
            let parts = identifier.split(separator: "/").map(String.init)
            guard !parts.isEmpty else { return nil }

            let region = parts.first ?? ""
            let cityToken = (parts.last ?? identifier).replacingOccurrences(of: "_", with: " ")
            let normalizedToken = Self.normalize(cityToken)

            let score: Int
            if normalizedToken == normalizedCity {
                score = 100
            } else if normalizedToken.hasPrefix(normalizedCity) || normalizedToken.contains(normalizedCity) {
                score = 70
            } else if Self.normalize(identifier).contains(normalizedCity) {
                score = 40
            } else {
                return nil
            }

            let inferredCode = Self.inferCountryCode(region: region, identifier: identifier)
            if let countryCode, inferredCode != countryCode {
                return nil
            }

            return (
                score,
                [
                    "city": .string(cityToken),
                    "countryCode": inferredCode.map(Value.string) ?? .null,
                    "timezoneId": .string(identifier),
                    "score": .int(score),
                    "source": .string("iana_identifier_heuristic")
                ]
            )
        }
        .sorted { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            return (lhs.payload["timezoneId"]?.stringValue ?? "") < (rhs.payload["timezoneId"]?.stringValue ?? "")
        }

        let limited = Array(matches.prefix(limit).map(\.payload))

        return .init(
            content: [.text(text: "Found \(limited.count) timezone candidate(s) for city '\(city)'.", annotations: nil, _meta: nil)],
            structuredContent: .object(["matches": .array(limited.map(Value.object))]),
            isError: false
        )
    }

    private static func normalize(_ input: String) -> String {
        input.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func inferCountryCode(region: String, identifier: String) -> String? {
        let upper = identifier.uppercased()
        if upper.contains("AMERICA/NEW_YORK") || upper.contains("AMERICA/CHICAGO") || upper.contains("AMERICA/LOS_ANGELES") {
            return "US"
        }
        if upper.contains("EUROPE/LONDON") { return "GB" }
        if upper.contains("EUROPE/PARIS") { return "FR" }
        if upper.contains("ASIA/TOKYO") { return "JP" }
        if upper.contains("AUSTRALIA/SYDNEY") { return "AU" }
        if upper.contains("ASIA/KOLKATA") { return "IN" }

        switch region {
        case "US": return "US"
        default: return nil
        }
    }
}
