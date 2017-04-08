import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import PromiseK
import ResultK

open class Request {
    open let method: Method
    open let url: URL
    open let parameters: [String: String]
    open let headers: [String: String]
    
    public init(method: Method, url: URL, parameters: [String: String] = [:], headers: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.parameters = parameters
        self.headers = headers
    }
    
    public convenience init?(method: Method, url: String, parameters: [String: String] = [:], headers: [String: String] = [:]) {
        guard let url = URL(string: url) else {
            return nil
        }
        self.init(method: method, url: url, parameters: parameters, headers: headers)
    }
    
    open func send() -> Promise<Result<Response>> {
        return Promise { resolve in
            let query = self.parameters.map { (percentEncode($0), percentEncode($1)) }.map { "\($0)=\($1)" }.joined(separator: "&")
            let request: NSURLRequest
            switch self.method {
            case .GET, .HEAD, .DELETE:
                let mutableRequest = NSMutableURLRequest(url: URL(string: self.url.absoluteString.appendingFormat("?\(query)")) ?? self.url)
                mutableRequest.httpMethod = self.method.rawValue
                request = mutableRequest
            default:
                let mutableRequest = NSMutableURLRequest(url: self.url)
                mutableRequest.httpMethod = self.method.rawValue
                mutableRequest.httpBody = query.data(using: String.Encoding.utf8)
                request = mutableRequest
            }
            
            let configuration = URLSessionConfiguration.ephemeral
            configuration.httpAdditionalHeaders = self.headers
            let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if let error = error {
                    resolve(pure(Result(error: error)))
                    return
                }
                
                switch response {
                case let response as HTTPURLResponse:
                    let headerFields = response.allHeaderFields.flatMap { (name, value) in
                        (name as? String).flatMap { name in (value as? String).flatMap { value in (name, value) } }
                    }
                    let headers: [String: String] = headerFields.reduce([:]) { (headers, field) in
                        var headers2 = headers
                        headers2[field.0] = field.1
                        return headers2
                    }
                    resolve(Promise(Result(Response(statusCode: response.statusCode, headers: headers, data: data))))
                default:
                    fatalError("Only HTTP and HTTPS are supported now: \(self.url.absoluteString)")
                }
            }
            task.resume()
        }
    }
}

private func percentEncode(_ string: String) -> String {
    return string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? string
}
