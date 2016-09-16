import XCTest
import Foundation
@testable import RequestK

class RequestTest: XCTestCase {
    func testBasic() {
        let expectation = self.expectation(description: "")

        let request = Request(method: .GET, url: "https://avatars2.githubusercontent.com/u/217100")!
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
        
        let request = Request(method: .GET, url: "https://qiita.com/api/v2/users", parameters: [
            "per_page": "3"
        ])!
        let response = request.send()
        _ = response.map { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.statusCode, 200)
                print(String(data: response.data!, encoding: String.Encoding.utf8))
                let users = try! JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                XCTAssertEqual(users.count, 3)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testHeaders() {
        let expectation = self.expectation(description: "")

        guard let accessTokenPath = Bundle(for: type(of: self)).path(forResource: "QiitaAccessToken", ofType: nil) else {
            XCTFail("Put a file named \"QiitaAccessToken\" in which an access token of Qiita with the read_qiita scope is written: https://qiita.com/settings/applications")
            return
        }
        let accessToken = try! NSString(contentsOfFile: accessTokenPath, encoding: String.Encoding.utf8.rawValue)
        let request = Request(method: .GET, url: "https://qiita.com/api/v2/authenticated_user", headers: [
            "Authorization" : "Bearer \(accessToken)"
        ])!
        let response = request.send()
        _ = response.map { result in
            switch result {
            case let .success(response):
                print("=== Qiita")
                XCTAssertEqual(response.statusCode, 200)
                print(response.headers)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
