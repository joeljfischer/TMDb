@testable import TMDb
import XCTest

class MockAPIClient: APIClient {

    static var apiKey: String?

    var result: Result<Any, TMDbError>?
    private(set) var lastPath: URL?
    private(set) var lastHTTPHeaders: [String: String]?

    static func setAPIKey(_ apiKey: String) {
        Self.apiKey = apiKey
    }

    func get<Response: Decodable>(path: URL, httpHeaders: [String: String]?) async throws -> Response {
        self.lastPath = path
        self.lastHTTPHeaders = httpHeaders

        guard let result = result else {
            throw TMDbError.unknown
        }

        do {
            guard let value = try result.get() as? Response else {
                XCTFail("Can't cast response to type \(String(describing: Response.self))")
                throw TMDbError.unknown
            }

            return value
        } catch let error as TMDbError {
            throw error
        } catch {
            throw TMDbError.unknown
        }
    }

    func reset() {
        result = nil
        lastPath = nil
        lastHTTPHeaders = nil
    }

}
