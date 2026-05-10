import MCP
import Testing
@testable import DateTimeMCPServer

@Test func unknownToolFailsFast() {
    let handlers = DateTimeToolHandlers(logger: DateTimeMCPServer.logger)
    #expect(throws: MCPError.self) {
        _ = try handlers.call(params: .init(name: "does_not_exist"))
    }
}

@Test func listToolsIncludesTimezoneTools() {
    let names = Set(DateTimeTool.allCases.map(\.rawValue))
    #expect(names.contains("get_current_datetime"))
    #expect(names.contains("list_timezones"))
    #expect(names.contains("get_timezone_info"))
    #expect(names.contains("lookup_timezone_by_city"))
}
