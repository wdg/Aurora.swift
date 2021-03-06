// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Please note: this is a beta version.
// It can contain bugs, please report all bugs to https://github.com/AuroraFramework/Aurora.swift
//
// Thanks for using!
//
// Licence: Needs to be decided.

// swiftlint:disable file_length
import Foundation

#if canImport(Security)
import Security
#endif

#if canImport(UIKit)
import UIKit
#endif

#if !targetEnvironment(simulator)
#if canImport(CommonCrypto)
import CommonCrypto
#endif
#endif

/// AuroraNetworkLogger ConfigurationType
public protocol AuroraNetworkLoggerConfigurationType {
    /// trim body at
    var bodyTrimLength: Int { get }
    
    /// NetworkLogger
    /// - Parameter string: String
    func auroraNetworkLogger(_ string: String)
    
    /// Enable capture for request?
    /// - Parameter request: request
    func enableCapture(_ request: URLRequest) -> Bool
}

extension AuroraNetworkLoggerConfigurationType {
    /// body trim length
    public var bodyTrimLength: Int {
        return 10000
    }
    
    /// networkLogger
    /// - Parameter string: log
    public func auroraNetworkLogger(_ string: String) {
        Aurora.shared.log(string)
    }
    
    /// Enable capture?
    /// - Parameter request: for request
    /// - Returns: bool
    public func enableCapture(_ request: URLRequest) -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

public struct AuroraNetworkLoggerDefaultConfiguration: AuroraNetworkLoggerConfigurationType {
    
}

public final class AuroraNetworkLogger: URLProtocol, URLSessionDelegate {
    // MARK: - Public
    
    /// AuroraNetworkLogger Configuration
    public static var configuration: AuroraNetworkLoggerConfigurationType = AuroraNetworkLoggerDefaultConfiguration()
    
    /// AuroraNetworkLogger Registration
    public class func register() {
        URLProtocol.registerClass(self)
    }
    
    /// AuroraNetworkLogger Deregistration
    public class func unregister() {
        URLProtocol.unregisterClass(self)
    }
    
    /// defaultSessionConfiguration
    /// - Returns: A configuration object that defines behavior and policies for a URL session.
    public class func defaultSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses?.insert(AuroraNetworkLogger.self, at: 0)
        return config
    }
    
    // MARK: - NSURLProtocol
    
    /// Can we init with request?
    /// - Parameter request: The request to be handled.
    /// - Returns: true if the protocol subclass can handle request, otherwise false.
    public override class func canInit(with request: URLRequest) -> Bool {
        guard AuroraNetworkLogger.configuration.enableCapture(request) == true else {
            return false
        }
        
        guard self.property(forKey: requestHandledKey, in: request) == nil else {
            return false
        }
        
        return true
    }
    
    /// Returns a canonical version of the specified request.
    /// - Parameter request: The request whose canonical version is desired.
    /// - Returns: The canonical form of request.
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// requestIsCacheEquivalent:toRequest:
    ///
    /// discussion Requests are considered euqivalent for cache purposes\
    /// if and only if they would be handled by the same protocol AND that
    /// protocol declares them equivalent after performing
    /// implementation-specific checks.
    ///
    /// - Parameters:
    ///   - testA: The request to compare with bRequest.
    ///   - testB: The request to compare with aRequest.
    /// - Returns: true if aRequest and bRequest are equivalent for cache purposes, false otherwise.
    public override class func requestIsCacheEquivalent(_ testA: URLRequest, to testB: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(testA, to: testB)
    }
    
    /// Starts protocol-specific loading of the request.
    ///
    /// When this method is called, the subclass implementation should start loading the request, \
    /// providing feedback to the URL loading system via the URLProtocolClient protocol.
    public override func startLoading() {
        guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest,
              newRequest == nil else { return }
        
        self.newRequest = req
        
        guard newRequest != nil else {
            return
        }
        
        AuroraNetworkLogger.setProperty(
            true,
            forKey: AuroraNetworkLogger.requestHandledKey,
            in: newRequest!
        )
        
        AuroraNetworkLogger.setProperty(
            Date(),
            forKey: AuroraNetworkLogger.requestTimeKey,
            in: newRequest!
        )
        
        let session = Foundation.URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil, // AuroraURLSessionPinningDelegate()
            delegateQueue: nil
        )
        
        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                self.logError(error as NSError)
                
                return
            }
            guard let response = response, let data = data else {
                print("Missing response, or data")
                return
            }
            
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            self.logResponse(response, data: data)
        }) .resume()
        
        logRequest(newRequest! as URLRequest)
    }
    
    /// Stop Loading
    public override func stopLoading() {
    }
    
    /// URL Session
    ///
    /// Tells the client that the protocol implementation has been redirected.
    ///
    /// - Parameters:
    ///   - session: Session
    ///   - task: URLSessionTask
    ///   - response: URLResponse
    ///   - request: request
    ///   - completionHandler: Completion handler (not used)
    func URLSession(
        _ session: Foundation.URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: (URLRequest?) -> Void) {
        self.client?.urlProtocol(
            self,
            wasRedirectedTo: request,
            redirectResponse: response
        )
    }
    
    // MARK: - Logging
    /// Log error
    /// - Parameter error: error
    public func logError(_ error: NSError) {
        self.log += "⚠️\n"
        self.log += "  Error: \n\(error.localizedDescription)\n"
        
        if let reason = error.localizedFailureReason {
            self.log += "  Reason: \(reason)\n"
        }
        
        if let suggestion = error.localizedRecoverySuggestion {
            self.log += "  Suggestion: \(suggestion)\n"
        }
        AuroraNetworkLogger.configuration.auroraNetworkLogger(self.log)
    }
    
    /// Log request
    /// - Parameter request: URL Request
    public func logRequest(_ request: URLRequest) {
        self.log = "Networklog\n"
        if let url = request.url?.absoluteString {
            self.log += "  \(request.httpMethod!) \(url)\n"
        }
        
        if let headers = request.allHTTPHeaderFields {
            self.log += "  Header:"
            self.log += logHeaders(headers as [String: AnyObject]) + "\n"
        }
        
        if let data = request.httpBody,
           let bodyString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            
            self.log += "  Body:\n"
            self.log += trimTextOverflow(
                bodyString as String,
                length: AuroraNetworkLogger.configuration.bodyTrimLength
            )
        }
        
        if let dataStream = request.httpBodyStream {
            let bufferSize = 1024
            var buffer = [UInt8](repeating: 0, count: bufferSize)
            
            let data = NSMutableData()
            dataStream.open()
            while dataStream.hasBytesAvailable {
                let bytesRead = dataStream.read(&buffer, maxLength: bufferSize)
                data.append(buffer, length: bytesRead)
            }
            
            logDataParser(data: data as Data)
        }
    }
    
    /// Dataparser fopr logger
    /// - Parameter data: data to be parsed
    private func logDataParser(data: Data) {
        do {
            let rawString = String.init(data: data, encoding: .utf8)
            let cleanData = (rawString?.removingPercentEncoding!.data(using: .utf8))!
            let json = try JSONSerialization.jsonObject(
                with: cleanData,
                options: .mutableContainers
            )
            
            let pretty = try JSONSerialization.data(
                withJSONObject: json,
                options: .prettyPrinted
            )
            
            if let string = NSString(
                data: pretty,
                encoding: String.Encoding.utf8.rawValue
            ) {
                self.log += "  POST JSON:\n"
                for line in string.components(separatedBy: "\n") {
                    self.log += "    " + line.replace("\" :", withString: "\":") + "\n"
                }
            }
            
            self.log += "  POST DATA:\n"
            self.log += "    " + (rawString ?? "Unable to decode.") + "\n"
        } catch {
            if let string = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
            )?.removingPercentEncoding! {
                self.log += "  Data:\n"
                for line in string.components(separatedBy: "\n") {
                    self.log += "    " + line + "\n"
                }
            }
        }
    }
    
    /// Log response
    /// - Parameters:
    ///   - response: URL Response
    ///   - data: URL Response Data
    public func logResponse(_ response: URLResponse, data: Data? = nil) {
        if let url = response.url?.absoluteString {
            self.log += "  Response: \(url)\n"
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let localisedStatus = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode).capitalized
            self.log += "  HTTP \(httpResponse.statusCode): \(localisedStatus)\n"
        }
        
        if let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: AnyObject] {
            self.log += "  Header:"
            self.log += self.logHeaders(headers) + "\n"
        }
        
        if let startDate = AuroraNetworkLogger.property(
            forKey: AuroraNetworkLogger.requestTimeKey,
            in: newRequest! as URLRequest
        ) as? Date {
            let difference = fabs(startDate.timeIntervalSinceNow)
            self.log += "  Duration: \(difference)s\n"
        }
        
        guard let data = data else { return }
        
        do {
            let json = try JSONSerialization.jsonObject(
                with: data,
                options: .mutableContainers
            )
            
            let pretty = try JSONSerialization.data(
                withJSONObject: json,
                options: .prettyPrinted
            )
            
            if let string = NSString(
                data: pretty,
                encoding: String.Encoding.utf8.rawValue
            ) {
                self.log += "  JSON:\n"
                for line in string.components(separatedBy: "\n") {
                    self.log += "    " + line.replace("\" :", withString: "\":") + "\n"
                }
            }
        } catch {
            if let string = NSString(
                data: data,
                encoding: String.Encoding.utf8.rawValue
            ) {
                self.log += "  Data:\n"
                for line in string.components(separatedBy: "\n") {
                    self.log += "    " + line + "\n"
                }
            }
        }
        
        AuroraNetworkLogger.configuration.auroraNetworkLogger(self.log)
    }
    
    /// Log headers
    /// - Parameter headers: Headers
    /// - Returns: Log
    public func logHeaders(_ headers: [String: AnyObject]) -> String {
        let string = headers.reduce(String()) { str, header in
            let string = "      \(header.0): \(header.1)"
            return str + "\n" + string
        }
        return string
    }
    
    // MARK: - Private
    
    /// requestHandledKey
    fileprivate static let requestHandledKey = "RequestLumberjackHandleKey"
    
    /// requestTimeKey
    fileprivate static let requestTimeKey = "RequestLumberjackRequestTime"
    
    /// Data container (for logs)
    fileprivate var data: NSMutableData?
    
    /// Response container (for logs)
    fileprivate var response: URLResponse?
    
    /// new Request container (for logs)
    fileprivate var newRequest: NSMutableURLRequest?
    
    /// Log container
    fileprivate var log = ""
    
    /// trimTextOverflow
    /// - Parameters:
    ///   - string: Log message
    ///   - length: Trim at.
    /// - Returns: Trimmed text
    fileprivate func trimTextOverflow(_ string: String, length: Int) -> String {
        guard string.count > length else {
            return string
        }
        
        return string[..<length] + "…"
    }
}
// swiftlint:enable file_length
