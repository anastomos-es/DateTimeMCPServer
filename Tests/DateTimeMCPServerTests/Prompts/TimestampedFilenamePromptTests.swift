import Testing
@testable import DateTimeMCPServer

@Test func timestampedFilenamePromptDefinitionMatchesPromptContract() {
    let definition = TimestampedFilenamePrompt.definition

    #expect(definition.name == DateTimePrompt.createTimestampedFilename.rawValue)
    #expect(definition.title == "Create Timestamped Filename")
    #expect(definition.arguments?.map(\.name) == ["basename", "extension"])
    #expect(definition.arguments?.map(\.required) == [true, false])
}

@Test func timestampedFilenamePromptRequiresBasename() throws {
    for arguments in [nil, [:], ["basename": ""], ["basename": "   "]] as [[String: String]?] {
        do {
            _ = try TimestampedFilenamePrompt(arguments: arguments)
            Issue.record("Expected missing basename to throw")
        } catch {
            #expect(String(describing: error).contains("Missing required argument 'basename'"))
        }
    }
}

@Test func timestampedFilenamePromptTrimsBasenameAndExtension() throws {
    let prompt = try TimestampedFilenamePrompt(
        arguments: [
            "basename": "  daily report  ",
            "extension": "  md  ",
        ]
    )

    #expect(prompt.basename == "daily report")
    #expect(prompt.fileExtension == "md")
}

@Test func timestampedFilenamePromptTreatsBlankExtensionAsMissing() throws {
    let prompt = try TimestampedFilenamePrompt(
        arguments: [
            "basename": "daily report",
            "extension": "   ",
        ]
    )

    #expect(prompt.fileExtension == nil)
}

@Test func timestampedFilenamePromptResponseIncludesExtensionInstruction() throws {
    let prompt = try TimestampedFilenamePrompt(
        arguments: [
            "basename": "daily report",
            "extension": "md",
        ]
    )
    let result = prompt.response

    guard case .text(let text)? = result.messages.first?.content else {
        Issue.record("Expected text prompt content")
        return
    }

    #expect(result.description == "Create a filesystem-safe timestamped filename.")
    #expect(result.messages.count == 1)
    #expect(text.contains("daily report"))
    #expect(text.contains("yyyy-MM-dd-HHmmss"))
    #expect(text.contains("Use `.md` as the file extension."))
    #expect(text.contains("Return only the filename."))
}

@Test func timestampedFilenamePromptResponseWithoutExtensionDoesNotInventOne() throws {
    let prompt = try TimestampedFilenamePrompt(arguments: ["basename": "daily report"])
    let result = prompt.response

    guard case .text(let text)? = result.messages.first?.content else {
        Issue.record("Expected text prompt content")
        return
    }

    #expect(text.contains("daily report"))
    #expect(text.contains("Do not add a file extension unless the request supplies one."))
}
