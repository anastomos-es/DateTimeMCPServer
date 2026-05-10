import Logging
import MCP

struct DateTimePromptHandlers {
    private let definitions: DateTimePromptDefinitions
    private let logger: Logger

    init(
        definitions: DateTimePromptDefinitions = DateTimePromptDefinitions(),
        logger: Logger = Logger(label: "ninja.chonky.mcp.date-time.prompts")
    ) {
        self.definitions = definitions
        self.logger = logger
    }

    func register(on server: Server) async {
        await server.withMethodHandler(ListPrompts.self) { _ in
            logger.debug("Listing available prompts")
            return ListPrompts.Result(prompts: definitions.all, nextCursor: nil)
        }

        await server.withMethodHandler(GetPrompt.self) { params in
            logger.info("Getting prompt", metadata: ["name": .string(params.name)])
            return try response(for: params)
        }
    }

    func response(for params: GetPrompt.Parameters) throws -> GetPrompt.Result {
        guard let prompt = DateTimePrompt(rawValue: params.name) else {
            throw MCPError.invalidParams("Unknown prompt: \(params.name)")
        }

        switch prompt {
        case .resolveRelativeDateTime:
            return try ResolveRelativeDateTimePrompt(arguments: params.arguments).response

        case .createTimestampedFilename:
            return try TimestampedFilenamePrompt(arguments: params.arguments).response
        }
    }
}
