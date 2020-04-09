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

import Foundation

protocol NetworkSession {
  func get(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void)
  func post(with request: URLRequest, completionHandler: @escaping (Data?, Error?) -> Void)
}

extension URLSession: NetworkSession {
  func post(with request: URLRequest, completionHandler: @escaping (Data?, Error?) -> Void) {
    let task = dataTask(with: request) { data, _, error in
      completionHandler(data, error)
    }
    task.resume()
  }
  
  func get(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
    let task = dataTask(with: url) { data, _, error in
      completionHandler(data, error)
    }
    task.resume()
  }
  
  
}

extension RazeCore {
  public class Networking {
    
    /// Responsible for handling all networking calls
    /// - Warning: Must create before using any public APIs
    public class Manager {
      public init() {}
      
      internal var session: NetworkSession = URLSession.shared
      
      /// Calls to the live internet to retrieve Data from a specific location
      /// - Parameters:
      ///   - url: The location you wish to fetch data from
      ///   - completionHandler: Returns a result object which signifies the status of the request
      public func loadData(from url: URL, completionHandler: @escaping (NetworkResult<Data>) -> Void) {
        session.get(from: url) { data, error in
          let result = data.map(NetworkResult<Data>.success) ?? .failure(error)
          completionHandler(result)
        }
      }
      
      /// Calls to the live internet to send data to a specific location
      /// - Warning: Make sure that the URL in question can accept a POST route
      /// - Parameters:
      ///   - url: The location you wish to send data to
      ///   - body: The object you wish to send over the network
      ///   - completionHandler: Returns a result object which signifies the status of the request
      public func sendData<I: Codable>(to url: URL, body: I, completionHandler: @escaping (NetworkResult<Data>) -> Void) {
        var request = URLRequest(url: url)
        do {
          let httpBody = try JSONEncoder().encode(body)
          request.httpBody = httpBody
          request.httpMethod = "POST"
          session.post(with: request) { data, error in
            let result = data.map(NetworkResult<Data>.success) ?? .failure(error)
            completionHandler(result)
          }
        } catch let error {
          return completionHandler(.failure(error))
        }
      }
    }
    
    public enum NetworkResult<Value> {
      case success(Value)
      case failure(Error?)
    }
  }
}
