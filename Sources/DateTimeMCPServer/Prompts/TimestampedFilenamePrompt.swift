import Foundation
import MCP

struct TimestampedFilenamePrompt {
    static let definition = Prompt(
        name: DateTimePrompt.createTimestampedFilename.rawValue,
        title: "Create Timestamped Filename",
        description: "Create a filesystem-safe filename using the server's current date and time.",
        arguments: [
            Prompt.Argument(
                name: "basename",
                title: "Base Name",
                description: "Base filename without the timestamp.",
                required: true
            ),
            Prompt.Argument(
                name: "extension",
                title: "Extension",
                description: "Optional file extension without a leading dot.",
                required: false
            )
        ]
    )

    let basename: String
    let fileExtension: String?

    init(arguments: [String: String]?) throws {
        guard let basename = arguments?["basename"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !basename.isEmpty else {
            throw MCPError.invalidParams("Missing required argument 'basename' for prompt '\(DateTimePrompt.createTimestampedFilename.rawValue)'")
        }

        self.basename = basename

        let cleanedExtension = arguments?["extension"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fileExtension = cleanedExtension?.isEmpty == false ? cleanedExtension : nil
    }

    var response: GetPrompt.Result {
        let extensionInstruction = fileExtension.map { "Use `.\($0)` as the file extension." }
            ?? "Do not add a file extension unless the request supplies one."

        return GetPrompt.Result(
            description: "Create a filesystem-safe timestamped filename.",
            messages: [
                .user(
                    .text(
                        text: """
                        Create a timestamped filename for this base name:
                        \(basename)

                        Call `get_current_datetime` first. Format the timestamp as `yyyy-MM-dd-HHmmss`. Use only ASCII letters, digits, dashes, underscores, and one dot before the extension. \(extensionInstruction) Return only the filename.
                        """
                    )
                )
            ]
        )
    }
}
