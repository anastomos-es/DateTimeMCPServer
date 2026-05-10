import Testing
@testable import DateTimeMCPServer

@Test func dateTimePromptRawValuesMatchMCPNames() {
    #expect(DateTimePrompt.resolveRelativeDateTime.rawValue == "resolve_relative_datetime")
    #expect(DateTimePrompt.createTimestampedFilename.rawValue == "create_timestamped_filename")
}

@Test func dateTimePromptAllCasesStayInDefinitionOrder() {
    #expect(DateTimePrompt.allCases == [
        .resolveRelativeDateTime,
        .createTimestampedFilename,
    ])
}

@Test func dateTimePromptDefinitionsUsePromptNames() {
    for prompt in DateTimePrompt.allCases {
        #expect(prompt.definition.name == prompt.rawValue)
    }
}

@Test func dateTimePromptDefinitionsHaveUniqueNames() {
    let names = DateTimePrompt.allCases.map(\.definition.name)

    #expect(Set(names).count == names.count)
}
