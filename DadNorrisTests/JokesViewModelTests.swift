import XCTest
import Swinject
import Combine
@testable import DadNorris

final class JokesViewModelTests: XCTestCase {
    var container: Container!
    var viewModel: JokesViewModel!
    var mockJokesAPI: MockJokesAPI!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        container = Container()
        container.register(JokesViewModel.self) { r in
            JokesViewModel(jokeAPI: r.resolve(JokesAPIProtocol.self)!)
        }
        
        container.register(JokesAPIProtocol.self) { _ in
            MockJokesAPI()
        }.inObjectScope(.container)
        
        mockJokesAPI = container.resolve(JokesAPIProtocol.self) as? MockJokesAPI
        viewModel = container.resolve(JokesViewModel.self)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        container = nil
        viewModel = nil
        mockJokesAPI = nil
        cancellables = nil
    }
    
    func testFetchDadJokes_Success() async {
        let expectedJokes = MockJokesAPI.dadJokesSampleData
        
        await viewModel.fetchDadJokes()
        
        XCTAssertEqual(viewModel.dadJokes, expectedJokes)
    }
    
    func testFetchDadJokes_Failure() async {
        mockJokesAPI.shouldThrowError = true
        
        await viewModel.fetchDadJokes()
        
        XCTAssertTrue(viewModel.dadJokes.isEmpty)
    }
    
    func testFetchChuckJokes_Success() async {
        let expectedJokes = MockJokesAPI.chuckJokesSampleData
        
        await viewModel.fetchChuckJokes()

        XCTAssertEqual(viewModel.chuckJokes, expectedJokes)
    }
    
    func testFetchChuckJokes_Failure() async {
        mockJokesAPI.shouldThrowError = true

        await viewModel.fetchChuckJokes()

        XCTAssertTrue(viewModel.chuckJokes.isEmpty)
    }
    
    func testFetchDadJokes_assignsCurrentDadJoke() async {
        XCTAssertNil(viewModel.currentDadJoke)
        
        await viewModel.fetchDadJokes()
        
        XCTAssertNotNil(viewModel.currentDadJoke)
    }
    
    func testFetchDadJokes_doesNotAssignDadJoke() async {
        mockJokesAPI.shouldThrowError = true
        XCTAssertNil(viewModel.currentDadJoke)
        
        await viewModel.fetchDadJokes()
        
        XCTAssertNil(viewModel.currentDadJoke)
    }
    
    func testFetchChuckJokes_assignsCurrentChuckJoke() async {
        XCTAssertNil(viewModel.currentChuckJoke)
        
        await viewModel.fetchChuckJokes()
        
        XCTAssertNotNil(viewModel.currentChuckJoke)
    }
    
    func testFetchDadJokes_doesNotAssignChuckJoke() async {
        mockJokesAPI.shouldThrowError = true
        XCTAssertNil(viewModel.currentChuckJoke)
        
        await viewModel.fetchChuckJokes()
        
        XCTAssertNil(viewModel.currentChuckJoke)
    }
    
    func testShowAnotherJoke_currentDadJokeChanged() async {
        viewModel.selectedSection = .dadJokes
        await viewModel.fetchDadJokes()
        let oldJoke = viewModel.currentDadJoke
        XCTAssertEqual(viewModel.currentDadJoke, oldJoke)
        
        viewModel.showAnotherJoke()
        
        XCTAssertNotEqual(viewModel.currentDadJoke, oldJoke)
    }
    
    func testFetchMoreJokesIfNeeded_needToFetch_fetchDadJokesIsCalled() async {
        let expectation = XCTestExpectation(description: "Fetch dad jokes if there is only 2 or less jokes left")
        viewModel.selectedSection = .dadJokes
        viewModel.dadJokes.append(contentsOf: MockJokesAPI.dadJokesSampleData)
        XCTAssertEqual(viewModel.dadJokes.count, 4)
        XCTAssertFalse(mockJokesAPI.fetchDadJokesCalled)
        
        mockJokesAPI.$fetchDadJokesCalled.sink { isCalled in
            if isCalled {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        viewModel.showAnotherJoke()
        viewModel.showAnotherJoke()
        viewModel.showAnotherJoke()
        
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(mockJokesAPI.fetchDadJokesCalled)
    }
    
    func testFetchMoreJokesIfNeeded_noNeedToFetch_fetchDadJokesIsNotCalled() async {
        viewModel.selectedSection = .dadJokes
        viewModel.dadJokes.append(contentsOf: MockJokesAPI.dadJokesSampleData)
        viewModel.currentDadJoke = viewModel.dadJokes.first!
        XCTAssertEqual(viewModel.dadJokes.count, 4)
        XCTAssertFalse(mockJokesAPI.fetchDadJokesCalled)
        
        viewModel.showAnotherJoke()
        
        XCTAssertFalse(mockJokesAPI.fetchDadJokesCalled)
    }
    
    func testFetchMoreJokesIfNeeded_needToFetch_fetchChuckJokesIsCalled() async {
        let expectation = XCTestExpectation(description: "Fetch chuck jokes because there 2 or less jokes left")
        viewModel.selectedSection = .chuckNorrisJokes
        viewModel.chuckJokes.append(contentsOf: MockJokesAPI.chuckJokesSampleData)
        viewModel.currentChuckJoke = viewModel.chuckJokes.first!
        XCTAssertEqual(viewModel.chuckJokes.count, 4)
        XCTAssertFalse(mockJokesAPI.fetchChuckJokesCalled)
        
        mockJokesAPI.$fetchChuckJokesCalled.sink { isCalled in
            if isCalled {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        viewModel.showAnotherJoke()
        viewModel.showAnotherJoke()
        
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(mockJokesAPI.fetchChuckJokesCalled)
    }
    
    func testFetchMoreJokesIfNeeded_noNeedToFetch_fetchChuckJokesIsNotCalled() async {
        viewModel.selectedSection = .chuckNorrisJokes
        viewModel.chuckJokes.append(contentsOf: MockJokesAPI.chuckJokesSampleData)
        viewModel.currentChuckJoke = viewModel.chuckJokes.first!
        XCTAssertEqual(viewModel.chuckJokes.count, 4)
        XCTAssertFalse(mockJokesAPI.fetchChuckJokesCalled)
        
        viewModel.showAnotherJoke()
        
        XCTAssertFalse(mockJokesAPI.fetchChuckJokesCalled)
    }
    
    func testFetchDadJokes_fetchStateWasSetToFetching() async {
        let expectation = XCTestExpectation(description: "Fetch state was set to fetching")
        XCTAssertEqual(viewModel.dadJokesFetchState, .idle)
        var fetchStates: [JokesViewModel.FetchState] = []
        
        viewModel.$dadJokesFetchState.sink { state in
            fetchStates.append(state)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        await viewModel.fetchDadJokes()
        
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertTrue(fetchStates.contains(.fetching))
        XCTAssertNotEqual(viewModel.dadJokesFetchState, .fetching)
    }
}
