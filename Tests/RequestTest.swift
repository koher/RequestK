import XCTest
@testable import RequestK

class RequestTest: XCTestCase {
    func testBasic() {
        let expectation = expectationWithDescription("")

        let request = Request(method: .GET, url: "https://avatars2.githubusercontent.com/u/217100")!
        let response = request.send()
        response.map { result in
            switch result {
            case let .Success(response):
                XCTAssertEqual(response.statusCode, 200)
                print(response.headers)
                XCTAssertEqual(response.data!, NSData(contentsOfURL: NSURL(string:"https://avatars2.githubusercontent.com/u/217100")!)!)
            case let .Failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testPost() {
        
    }
    
    func testParameters() {
        let expectation = expectationWithDescription("")
        
        let request = Request(method: .GET, url: "https://qiita.com/api/v2/users", parameters: [
            "per_page": "3"
        ])!
        let response = request.send()
        response.map { result in
            switch result {
            case let .Success(response):
                XCTAssertEqual(response.statusCode, 200)
                print(NSString(data: response.data!, encoding: NSUTF8StringEncoding))
                let users = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.AllowFragments) as! NSArray
                XCTAssertEqual(users.count, 3)
            case let .Failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testHeaders() {
        let expectation = expectationWithDescription("")

        guard let accessTokenPath = NSBundle(forClass: self.dynamicType).pathForResource("QiitaAccessToken", ofType: nil) else {
            XCTFail("Put a file named \"QiitaAccessToken\" in which an access token of Qiita with the read_qiita scope is written: https://qiita.com/settings/applications")
            return
        }
        let accessToken = try! NSString(contentsOfFile: accessTokenPath, encoding: NSUTF8StringEncoding)
        let request = Request(method: .GET, url: "https://qiita.com/api/v2/authenticated_user", headers: [
            "Authorization" : "Bearer \(accessToken)"
        ])!
        let response = request.send()
        response.map { result in
            switch result {
            case let .Success(response):
                print("=== Qiita")
                XCTAssertEqual(response.statusCode, 200)
                print(response.headers)
            case let .Failure(error):
                XCTFail("\(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
