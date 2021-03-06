/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.



import XCTest
@testable import RazeCore

class NetworkSessionMock: NetworkSession {
  var data: Data?
  var error: Error?
  
  func get(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
    completionHandler(data, error)
  }
  
  func post(with request: URLRequest, completionHandler: @escaping (Data?, Error?) -> Void) {
    completionHandler(data, error)
  }
}

struct MockData: Codable, Equatable {
  var id: Int
  var name: String
}

final class RazeNetworkingTests: XCTestCase {
  func testLoadDataCall() {
    let manager = RazeCore.Networking.Manager()
    let session = NetworkSessionMock()
    manager.session = session
    let expectation = XCTestExpectation(description: "Called for data")
    let data = Data([0, 1, 0, 1])
    session.data = data
    let url = URL(fileURLWithPath: "url")
    manager.loadData(from: url) { result in
      expectation.fulfill()
      switch result {
        case .success(let returnedData):
          XCTAssertEqual(data, returnedData, "manager returned unexpected data")
        case .failure(let error):
          XCTFail(error?.localizedDescription ?? "error forming error result")
      }
    }
    wait(for: [expectation], timeout: 5)
  }
  
  func testSendDataCall() {
    let session = NetworkSessionMock()
    let manager = RazeCore.Networking.Manager()
    let sampleObject = MockData(id: 1, name: "David")
    let data = try? JSONEncoder().encode(sampleObject)
    session.data = data
    manager.session = session
    let url = URL(fileURLWithPath: "url")
    let expectation = XCTestExpectation(description: "Sent data")
    manager.sendData(to: url, body: sampleObject) { result in
      expectation.fulfill()
      switch result {
        case .success(let returnedData):
          let returnedObject = try? JSONDecoder().decode(MockData.self, from: returnedData)
          XCTAssertEqual(returnedObject, sampleObject)
          break
        case .failure(let error):
          XCTFail(error?.localizedDescription ?? "error forming error result")
      }
    }
    wait(for: [expectation], timeout: 5)
  }
  
  static var allTests = [
    ("testLoadDataCall", testLoadDataCall),
    ("testSendDataCall", testSendDataCall)
  ]
}
