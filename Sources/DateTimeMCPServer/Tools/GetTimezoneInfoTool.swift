import Foundation
import MCP

struct GetTimezoneInfoTool: Sendable {
    static let definition = Tool(
        name: DateTimeTool.getTimezoneInfo.rawValue,
        description: "Get DST-aware timezone details for now or a supplied timestamp",
        inputSchema: .object([
            "type": "object",
            "properties": [
                "timezoneId": ["type": "string"],
                "at": ["type": "string", "description": "ISO-8601 timestamp"]
            ],
            "required": ["timezoneId"]
        ])
    )

    func call(arguments: [String: Value]?) throws -> CallTool.Result {
        let parser = ToolArgumentParser(arguments: arguments)
        let timezoneId = try parser.requiredString("timezoneId")
        guard let timezone = TimeZone(identifier: timezoneId) else {
            throw MCPError.invalidParams("Unknown timezone identifier: \(timezoneId)")
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let at: Date
        if let atRaw = try parser.optionalString("at") {
            guard let parsed = formatter.date(from: atRaw) ?? ISO8601DateFormatter().date(from: atRaw) else {
                throw MCPError.invalidParams("Argument 'at' must be an ISO-8601 timestamp")
            }
            at = parsed
        } else {
            at = Date()
        }

        let nextTransition = timezone.nextDaylightSavingTimeTransition(after: at)
        let structured: Value = .object([
            "timezoneId": .string(timezone.identifier),
            "at": .string(formatter.string(from: at)),
            "secondsFromGMT": .int(timezone.secondsFromGMT(for: at)),
            "abbreviation": .string(timezone.abbreviation(for: at) ?? ""),
            "isDST": .bool(timezone.isDaylightSavingTime(for: at)),
            "daylightSavingOffsetSeconds": .double(timezone.daylightSavingTimeOffset(for: at)),
            "nextDSTTransition": nextTransition.map { .string(formatter.string(from: $0)) } ?? .null
        ])

        return CallTool.Result(
            content: [.text(text: "Timezone \(timezone.identifier) at \(formatter.string(from: at))", annotations: nil, _meta: nil)],
            structuredContent: Optional.some(structured),
            isError: false
        )
    }
}
