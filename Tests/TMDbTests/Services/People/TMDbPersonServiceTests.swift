@testable import TMDb
import XCTest

final class TMDbPersonServiceTests: XCTestCase {

    var service: TMDbPersonService!
    var apiClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        service = TMDbPersonService(apiClient: apiClient)
    }

    override func tearDown() {
        apiClient = nil
        service = nil
        super.tearDown()
    }

    func testDetailsReturnsPerson() async throws {
        let expectedResult = Person.mock
        let personID = expectedResult.id
        apiClient.result = .success(expectedResult)

        let result = try await service.details(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.details(personID: personID).path)
    }

    func testCombinedCreditsReturnsCombinedCredits() async throws {
        let mock = PersonCombinedCredits.mock
        let expectedResult = PersonCombinedCredits(id: mock.id, cast: mock.cast.sorted(), crew: mock.crew.sorted())
        let personID = expectedResult.id
        apiClient.result = .success(expectedResult)

        let result = try await service.combinedCredits(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.combinedCredits(personID: personID).path)
    }

    func testMovieCreditsReturnsMovieCredits() async throws {
        let mock = PersonMovieCredits.mock
        let expectedResult = PersonMovieCredits(id: mock.id, cast: mock.cast.sorted(), crew: mock.crew.sorted())
        let personID = expectedResult.id
        apiClient.result = .success(expectedResult)

        let result = try await service.movieCredits(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.movieCredits(personID: personID).path)
    }

    func testTVShowCreditsReturnsTVShowCredits() async throws {
        let mock = PersonTVShowCredits.mock
        let expectedResult = PersonTVShowCredits(id: mock.id, cast: mock.cast.sorted(), crew: mock.crew.sorted())
        let personID = expectedResult.id
        apiClient.result = .success(expectedResult)

        let result = try await service.tvShowCredits(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.tvShowCredits(personID: personID).path)
    }

    func testImagesReturnsImageCollection() async throws {
        let expectedResult = PersonImageCollection.mock
        let personID = expectedResult.id
        apiClient.result = .success(expectedResult)

        let result = try await service.images(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.images(personID: personID).path)
    }

    func testKnownForReturnsShows() async throws {
        let credits = PersonCombinedCredits.mock
        let personID = credits.id
        apiClient.result = .success(credits)
        let topCastShows = Array(credits.cast.sorted().prefix(10))
        let topCrewShows = Array(credits.crew.sorted().prefix(10))
        var topShows = topCastShows + topCrewShows
        topShows = topShows.reduce([], { shows, show in
            var shows = shows
            if !shows.contains(where: { $0.id == show.id }) {
                shows.append(show)
            }

            return shows
        })

        topShows.sort { $0.popularity ?? 0 > $1.popularity ?? 0 }

        let expectedResult = Array(topShows.prefix(10))

        let result = try await service.knownFor(forPerson: personID)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.combinedCredits(personID: personID).path)
    }

    func testPopularWithDefaultParametersReturnsPeople() async throws {
        let expectedResult = PersonPageableList.mock
        apiClient.result = .success(expectedResult)

        let result = try await service.popular()

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.popular().path)
    }

    func testPopularReturnsPeople() async throws {
        let expectedResult = PersonPageableList.mock
        apiClient.result = .success(expectedResult)

        let result = try await service.popular(page: nil)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.popular().path)
    }

    func testPopularWithPageReturnsPeople() async throws {
        let expectedResult = PersonPageableList.mock
        let page = expectedResult.page
        apiClient.result = .success(expectedResult)

        let result = try await service.popular(page: page)

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(apiClient.lastPath, PeopleEndpoint.popular(page: page).path)
    }

}
