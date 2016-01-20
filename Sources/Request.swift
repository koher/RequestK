import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import PromiseK
import ResultK

public class Request {
    public let method: Method
    public let url: NSURL
    public let parameters: [String: String]
    public let headers: [String: String]
    
    public init(method: Method, url: NSURL, parameters: [String: String] = [:], headers: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.parameters = parameters
        self.headers = headers
    }
    
    public convenience init?(method: Method, url: String, parameters: [String: String] = [:], headers: [String: String] = [:]) {
        guard let url = NSURL(string: url) else {
            return nil
        }
        self.init(method: method, url: url, parameters: parameters, headers: headers)
    }
    
    public func send() -> Promise<Result<Response>> {
        return Promise { resolve in
            let query = self.parameters.map { (percentEncode($0), percentEncode($1)) }.map { "\($0)=\($1)" }.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
            let request: NSURLRequest
            switch self.method {
            case .GET, .HEAD, .DELETE:
                let mutableRequest = NSMutableURLRequest(URL: NSURL(string: self.url.absoluteString.stringByAppendingString("?\(query)")) ?? self.url)
                mutableRequest.HTTPMethod = self.method.rawValue
                request = mutableRequest
            default:
                let mutableRequest = NSMutableURLRequest(URL: self.url)
                mutableRequest.HTTPMethod = self.method.rawValue
                mutableRequest.HTTPBody = query
                request = mutableRequest
            }
            
            let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            configuration.HTTPAdditionalHeaders = self.headers
            let session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
            
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if let error = error {
                    resolve(pure(Result(error: error)))
                    return
                }
                
                switch response {
                case let response as NSHTTPURLResponse:
                    let headerFields = response.allHeaderFields.flatMap { (name, value) in
                        (name as? String).flatMap { name in (value as? String).flatMap { value in (name, value) } }
                    }
                    let headers: [String: String] = headerFields.reduce([:]) { (var headers, field) in headers[field.0] = field.1; return headers }
                    resolve(pure(pure(Response(statusCode: response.statusCode, headers: headers, data: data))))
                default:
                    fatalError("Only HTTP and HTTPS are supported now: \(self.url.absoluteString)")
                }
            }
            task.resume()
        }
    }
}

private func percentEncode(string: String) -> String {
    return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? string
}
