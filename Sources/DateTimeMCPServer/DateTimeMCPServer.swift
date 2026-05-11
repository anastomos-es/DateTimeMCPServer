import Foundation
import Logging
import MCP
import System

@main
struct DateTimeMCPServer {
    static let logger = Logger(label: "ninja.chonky.mcp.date-time")

    static func main() async throws {
        logger.info("Server boot starting")

        let server = Server(
            name: "date-time-server",
            version: "1.0.0",
            capabilities: .init(
                prompts: .init(),
                resources: .init(subscribe: true),
                tools: .init()
            )
        )

        logger.info("Registering tools")
        await DateTimeToolHandlers(logger: logger).register(on: server)

        logger.info("Registering prompts")
        await DateTimePromptHandlers(logger: logger).register(on: server)

        await server.onNotification(ResourceUpdatedNotification.self) { _ in }

        let transport = StdioTransport(logger: logger)
        try await server.start(transport: transport) { clientInfo, clientCapabilities in
            guard clientInfo.name != "BlockedClient" else {
                throw MCPError.invalidRequest("This client is not allowed")
            }

            if clientCapabilities.sampling == nil {
                logger.info("Client does not support sampling")
            }

            logger.info("Client \(clientInfo.name) v\(clientInfo.version) connected")
        }

        logger.info("Server started")
        await server.waitUntilCompleted()
    }
}
