import Foundation
import Logging
import MCP

struct DateTimeToolHandlers: Sendable {
    private let logger: Logger
    private let listTimezonesTool: ListTimezonesTool
    private let getTimezoneInfoTool: GetTimezoneInfoTool
    private let lookupTimezoneByCityTool: LookupTimezoneByCityTool

    init(
        logger: Logger,
        listTimezonesTool: ListTimezonesTool = .init(),
        getTimezoneInfoTool: GetTimezoneInfoTool = .init(),
        lookupTimezoneByCityTool: LookupTimezoneByCityTool = .init()
    ) {
        self.logger = logger
        self.listTimezonesTool = listTimezonesTool
        self.getTimezoneInfoTool = getTimezoneInfoTool
        self.lookupTimezoneByCityTool = lookupTimezoneByCityTool
    }

    func register(on server: Server) async {
        logger.info("Registering tool handlers")

        await server.withMethodHandler(ListTools.self) { _ in
            .init(tools: DateTimeTool.allCases.map(\.definition))
        }

        await server.withMethodHandler(CallTool.self) { params in
            logger.info("CallTool handler called: \(params.name)")
            return try call(params: params)
        }
    }

    func call(params: CallTool.Parameters) throws -> CallTool.Result {
        guard let tool = DateTimeTool(rawValue: params.name) else {
            throw MCPError.invalidParams("Unknown tool: \(params.name)")
        }

        switch tool {
        case .getCurrentDateTime:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = formatter.string(from: Date())
            return .init(
                content: [.text(text: "Current date and time: \(now)", annotations: nil, _meta: nil)],
                structuredContent: .object(["currentDateTime": .string(now)]),
                isError: false
            )
        case .listTimezones:
            return try listTimezonesTool.call(arguments: params.arguments)
        case .getTimezoneInfo:
            return try getTimezoneInfoTool.call(arguments: params.arguments)
        case .lookupTimezoneByCity:
            return try lookupTimezoneByCityTool.call(arguments: params.arguments)
        }
    }
}
