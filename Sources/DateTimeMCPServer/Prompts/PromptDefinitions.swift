import MCP

struct DateTimePromptDefinitions {
    var all: [Prompt] {
        DateTimePrompt.allCases.map(\.definition)
    }
}
