import Testing
@testable import DateTimeMCPServer

@Test func relativeDateTimePromptDefinitionMatchesPromptContract() {
    let definition = ResolveRelativeDateTimePrompt.definition

    #expect(definition.name == DateTimePrompt.resolveRelativeDateTime.rawValue)
    #expect(definition.title == "Resolve Relative Date/Time")
    #expect(definition.arguments?.count == 1)
    #expect(definition.arguments?.first?.name == "request")
    #expect(definition.arguments?.first?.required == true)
}

@Test func relativeDateTimePromptRequiresRequest() throws {
    for arguments in [nil, [:], ["request": ""], ["request": "   "]] as [[String: String]?] {
        do {
            _ = try ResolveRelativeDateTimePrompt(arguments: arguments)
            Issue.record("Expected missing request to throw")
        } catch {
            #expect(String(describing: error).contains("Missing required argument 'request'"))
        }
    }
}

@Test func relativeDateTimePromptTrimsRequest() throws {
    let prompt = try ResolveRelativeDateTimePrompt(arguments: ["request": "  What is tomorrow?  "])

    #expect(prompt.request == "What is tomorrow?")
}

@Test func relativeDateTimePromptResponseContainsRequestAndToolInstruction() throws {
    let prompt = try ResolveRelativeDateTimePrompt(arguments: ["request": "What happens next week?"])
    let result = prompt.response

    guard case .text(let text)? = result.messages.first?.content else {
        Issue.record("Expected text prompt content")
        return
    }

    #expect(result.description == "Ground the request in the current server date and time.")
    #expect(result.messages.count == 1)
    #expect(text.contains("What happens next week?"))
    #expect(text.contains("get_current_datetime"))
    #expect(text.contains("today"))
    #expect(text.contains("tomorrow"))
    #expect(text.contains("next month"))
}

@Test func relativeDateTimePromptIgnoresUnrelatedArguments() throws {
    let prompt = try ResolveRelativeDateTimePrompt(
        arguments: [
            "request": "What is today?",
            "unused": "ignored",
        ]
    )

    #expect(prompt.request == "What is today?")
}
