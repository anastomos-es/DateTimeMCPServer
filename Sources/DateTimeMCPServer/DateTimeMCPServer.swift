import MCP
import System
import Foundation
import Logging

@main
struct DateTimeMCPServer {
    static let logger = Logger(label: "ninja.chonky.mcp.date-time")

    static func main() async throws {
        await withThrowingTaskGroup { group in

            group.addTask {
                print("Starting DateTimeMCPServer")
                // Create a server that provides current date/time
                let server = Server(
                    name: "date-time-server",
                    version: "1.0.0",
                    capabilities: .init(
                        prompts: .init(),
                        resources: .init(
                            subscribe: true
                        ),
                        tools: .init()
                    )
                )

                // Start the server using STDIO transport (ideal for local MCP servers)
                let transport = StdioTransport(logger: logger)

                logger.info("About to start server")
                // try await server.start(transport: transport)
                // Start the server with an initialize hook
                try await server.start(transport: transport) { clientInfo, clientCapabilities in
                    // Validate client info
                    guard clientInfo.name != "BlockedClient" else {
                        throw MCPError.invalidRequest("This client is not allowed")
                    }

                    // You can also inspect client capabilities
                    if clientCapabilities.sampling == nil {
                        logger.info("Client does not support sampling")
                    }

                    // Perform any server-side setup based on client info
                    logger.info("Client \(clientInfo.name) v\(clientInfo.version) connected")

                    // If the hook completes without throwing, initialization succeeds
                }
                logger.info("Server started")

                // Register tool handlers
                await server.withMethodHandler(ListTools.self) { _ in
                    logger.info("ListTools handler called")

                    return .init(tools: [
                        Tool(name: "get_current_datetime", description: "Get the current date and time", inputSchema: .object(["type": "object", "properties": [:]]))
                    ])
                }

                // Handle tool calls
                await server.withMethodHandler(CallTool.self) { params in
                    logger.info("CallTool handler called: \(params.name)")
                    switch params.name {
                    case "get_current_datetime":
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let currentDateTime = formatter.string(from: Date())

                        // Use the new initializer: .text(text:annotations:_meta:)
                        return .init(
                            content: [
                                .text(text: "Current date and time: \(currentDateTime)", annotations: nil, _meta: nil)
                            ],
                            isError: false
                        )

                    default:
                        return .init(
                            content: [
                                .text(text: "Unknown tool: \(params.name)", annotations: nil, _meta: nil)
                            ],
                            isError: true
                        )
                    }
                }

                // Register notification handlers
                logger.info("Registering notifications")
                await server.onNotification(ResourceUpdatedNotification.self) { message in
                    // Handle resource update notification
                }


                await server.waitUntilCompleted()
            }
        }
    }
}
