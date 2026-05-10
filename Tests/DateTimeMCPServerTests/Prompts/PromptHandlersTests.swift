import MCP
import Testing
@testable import DateTimeMCPServer

@Test func promptHandlersRouteRelativeDateTimePrompt() throws {
    let result = try DateTimePromptHandlers().response(
        for: GetPrompt.Parameters(
            name: DateTimePrompt.resolveRelativeDateTime.rawValue,
            arguments: ["request": "What is tomorrow?"]
        )
    )

    guard case .text(let text)? = result.messages.first?.content else {
        Issue.record("Expected text prompt content")
        return
    }

    #expect(result.description == "Ground the request in the current server date and time.")
    #expect(text.contains("What is tomorrow?"))
    #expect(text.contains("get_current_datetime"))
}

@Test func promptHandlersRouteTimestampedFilenamePrompt() throws {
    let result = try DateTimePromptHandlers().response(
        for: GetPrompt.Parameters(
            name: DateTimePrompt.createTimestampedFilename.rawValue,
            arguments: [
                "basename": "daily report",
                "extension": "md",
            ]
        )
    )

    guard case .text(let text)? = result.messages.first?.content else {
        Issue.record("Expected text prompt content")
        return
    }

    #expect(result.description == "Create a filesystem-safe timestamped filename.")
    #expect(text.contains("daily report"))
    #expect(text.contains(".md"))
}

@Test func promptHandlersRejectUnknownPrompt() throws {
    do {
        _ = try DateTimePromptHandlers().response(
            for: GetPrompt.Parameters(name: "unknown_prompt", arguments: [:])
        )
        Issue.record("Expected unknown prompt to throw")
    } catch {
        #expect(String(describing: error).contains("Unknown prompt: unknown_prompt"))
    }
}

@Test func promptHandlersCanRegisterWithServer() async {
    let server = Server(
        name: "test-date-time-server",
        version: "1.0.0",
        capabilities: .init(prompts: .init())
    )

    await DateTimePromptHandlers().register(on: server)
}
