import MCP
import Testing
@testable import DateTimeMCPServer

@Test func listTimezonesSupportsFilteringAndPagination() throws {
    let tool = ListTimezonesTool()
    let result = try tool.call(arguments: ["region": .string("America"), "limit": .int(2), "cursor": .string("0")])
    let structured = try #require(result.structuredContent?.objectValue)
    let items = try #require(structured["items"]?.arrayValue)
    #expect(items.count == 2)
    let total = try #require(structured["totalMatched"]?.intValue)
    #expect(total >= 2)
}

@Test func listTimezonesRejectsInvalidLimit() {
    let tool = ListTimezonesTool()
    #expect(throws: MCPError.self) {
        _ = try tool.call(arguments: ["limit": .int(0)])
    }
}
