import Foundation

import ResultK

public struct Response {
    public let statusCode: Int
    public let headers: [String: String]
    public let data: NSData?
}