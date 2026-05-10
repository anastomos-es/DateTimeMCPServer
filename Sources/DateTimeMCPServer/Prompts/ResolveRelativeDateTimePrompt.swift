import Foundation
import MCP

struct ResolveRelativeDateTimePrompt {
    static let definition = Prompt(
        name: DateTimePrompt.resolveRelativeDateTime.rawValue,
        title: "Resolve Relative Date/Time",
        description: "Ground a date/time-sensitive request in the server's current date and time.",
        arguments: [
            Prompt.Argument(
                name: "request",
                title: "Request",
                description: "The date/time-sensitive request to answer.",
                required: true
            )
        ]
    )

    let request: String

    init(arguments: [String: String]?) throws {
        guard let request = arguments?["request"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !request.isEmpty else {
            throw MCPError.invalidParams("Missing required argument 'request' for prompt '\(DateTimePrompt.resolveRelativeDateTime.rawValue)'")
        }

        self.request = request
    }

    var response: GetPrompt.Result {
        GetPrompt.Result(
            description: "Ground the request in the current server date and time.",
            messages: [
                .user(
                    .text(
                        text: """
                        Use DateTimeMCPServer to answer this date/time-sensitive request.

                        Request: \(request)

                        Call `get_current_datetime` before answering. Treat that result as the authoritative current date and time for relative words such as today, tomorrow, yesterday, this week, and next month. Include the exact date/time used when it changes the answer.
                        """
                    )
                )
            ]
        )
    }
}
