import XCTest
import Foundation
@testable import RequestK

class RequestTest: XCTestCase {
    func testBasic() {
        let expectation = self.expectation(description: "")

        let request = Request(method: .get, url: "https://avatars2.githubusercontent.com/u/217100")!
        let response = request.send()
        _ = response.map { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                print(response.headers)
                XCTAssertEqual(response.data!, try! Data(contentsOf: URL(string:"https://avatars2.githubusercontent.com/u/217100")!))
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testPost() {
        
    }
    
    func testParameters() {
        let expectation = self.expectation(description: "")
        
        let request = Request(method: .get, url: "https://qiita.com/api/v2/users", parameters: [
            "per_page": "3"
        ])!
        let response = request.send()
        _ = response.map { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                print(String(data: response.data!, encoding: String.Encoding.utf8)!)
                let users = try! JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
                XCTAssertEqual(users.count, 3)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testHeaders() {
        let accessTokenPath = #file.deletingLastPathComponent.deletingLastPathComponent.appendingPathComponent("QiitaAccessToken")
        guard FileManager.default.fileExists(atPath: accessTokenPath) else {
            XCTFail("Put a file to \"\(accessTokenPath)\" in which an access token of Qiita with the read_qiita scope is written: https://qiita.com/settings/applications")
            return
        }
        let accessToken = try! String(contentsOfFile: accessTokenPath, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let expectation = self.expectation(description: "")
        
        let request = Request(method: .get, url: "https://qiita.com/api/v2/authenticated_user", headers: [
            "Authorization" : "Bearer \(accessToken)"
        ])!
        let response = request.send()
        _ = response.map { result in
            switch result {
            case let .success(response):
                print("=== Qiita")
                XCTAssertEqual(response.statusCode, 200, String(data: response.data!, encoding: .utf8)!)
                print(response.headers)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

extension String {
    fileprivate var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    fileprivate func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}
