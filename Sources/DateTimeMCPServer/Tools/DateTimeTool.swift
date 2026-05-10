import Foundation
import MCP

enum DateTimeTool: String, CaseIterable, Sendable {
    case getCurrentDateTime = "get_current_datetime"
    case listTimezones = "list_timezones"
    case getTimezoneInfo = "get_timezone_info"
    case lookupTimezoneByCity = "lookup_timezone_by_city"

    var definition: Tool {
        switch self {
        case .getCurrentDateTime:
            Tool(name: rawValue, description: "Get the current date and time", inputSchema: .object(["type": "object", "properties": [:]]))
        case .listTimezones:
            ListTimezonesTool.definition
        case .getTimezoneInfo:
            GetTimezoneInfoTool.definition
        case .lookupTimezoneByCity:
            LookupTimezoneByCityTool.definition
        }
    }
}
