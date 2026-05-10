import MCP

enum DateTimePrompt: String, CaseIterable {
    case resolveRelativeDateTime = "resolve_relative_datetime"
    case createTimestampedFilename = "create_timestamped_filename"

    var definition: Prompt {
        switch self {
        case .resolveRelativeDateTime:
            return ResolveRelativeDateTimePrompt.definition

        case .createTimestampedFilename:
            return TimestampedFilenamePrompt.definition
        }
    }
}
