import Testing
@testable import DateTimeMCPServer

@Test func promptDefinitionsExposeEveryDateTimePrompt() {
    let definitions = DateTimePromptDefinitions().all

    #expect(definitions.map(\.name) == DateTimePrompt.allCases.map(\.rawValue))
}

@Test func promptDefinitionsExposeRequiredAndOptionalArguments() {
    let definitions = DateTimePromptDefinitions().all
    let relativeDateTime = definitions[0]
    let timestampedFilename = definitions[1]

    #expect(relativeDateTime.arguments?.map(\.name) == ["request"])
    #expect(relativeDateTime.arguments?.map(\.required) == [true])

    #expect(timestampedFilename.arguments?.map(\.name) == ["basename", "extension"])
    #expect(timestampedFilename.arguments?.map(\.required) == [true, false])
}

@Test func promptDefinitionsExposeHumanReadableTitlesAndDescriptions() {
    let definitions = DateTimePromptDefinitions().all

    #expect(definitions[0].title == "Resolve Relative Date/Time")
    #expect(definitions[0].description?.contains("date/time-sensitive request") == true)

    #expect(definitions[1].title == "Create Timestamped Filename")
    #expect(definitions[1].description?.contains("filesystem-safe filename") == true)
}
