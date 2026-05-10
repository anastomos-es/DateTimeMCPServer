import MCP
import Testing
@testable import DateTimeMCPServer

@Test func timezoneInfoIncludesDSTFields() throws {
    let tool = GetTimezoneInfoTool()
    let result = try tool.call(arguments: [
        "timezoneId": .string("America/New_York"),
        "at": .string("2026-07-01T12:00:00.000Z")
    ])

    let structured = try #require(result.structuredContent?.objectValue)
    #expect(structured["isDST"]?.boolValue != nil)
    #expect(structured["secondsFromGMT"]?.intValue != nil)
    #expect(structured["daylightSavingOffsetSeconds"]?.doubleValue != nil)
}

@Test func timezoneInfoRejectsUnknownZone() {
    let tool = GetTimezoneInfoTool()
    #expect(throws: MCPError.self) {
        _ = try tool.call(arguments: ["timezoneId": .string("Mars/Olympus")])
    }
}

@Test func cityLookupSupportsCountryNarrowing() throws {
    let tool = LookupTimezoneByCityTool()
    let result = try tool.call(arguments: ["city": .string("New York"), "countryCode": .string("US"), "limit": .int(3)])
    let structured = try #require(result.structuredContent?.objectValue)
    let matches = try #require(structured["matches"]?.arrayValue)
    #expect(!matches.isEmpty)
}
