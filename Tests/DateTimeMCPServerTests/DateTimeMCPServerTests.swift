import Testing
@testable import DateTimeMCPServer

@Test func serverLoggerUsesDateTimeLabel() {
    #expect(DateTimeMCPServer.logger.label == "ninja.chonky.mcp.date-time")
}
