//
//  EventsListViewModelTests.swift
//  BigBetTests
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import BigBet

class EventsListViewModelTests: XCTestCase {

    var viewModel: EventsListViewModel!
    var mockBetsUseCase: MockBetsUseCase!
    var mockEventsUseCase: MockEventsUseCase!
    var mockNetworkService: MockNetworkService!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        mockNetworkService = MockNetworkService()

        let mockNetworkService = MockNetworkService()
        mockEventsUseCase = MockEventsUseCase(networkManager: mockNetworkService)

        let mockBetStorage = MockBetStorage()
        let mockAnalyticsUseCase = MockAnalyticsUseCase()
        mockBetsUseCase = MockBetsUseCase(storage: mockBetStorage, analyticsUseCase: mockAnalyticsUseCase)

        viewModel = EventsListViewModel(eventsUseCase: mockEventsUseCase, betsUseCase: mockBetsUseCase)
    }

    override func tearDown() {
        viewModel = nil
        mockBetsUseCase = nil
        mockEventsUseCase = nil
        disposeBag = nil
        scheduler = nil
        super.tearDown()
    }

    // Test if events are fetched and set correctly
    func testFetchEventsSuccess() {
        let expectation = self.expectation(description: "Events fetched")

        viewModel.events
            .skip(1)
            .subscribe(onNext: { events in
                XCTAssertFalse(events.isEmpty, "Events should not be empty")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        viewModel.fetchEvents()
        waitForExpectations(timeout: 2, handler: nil)
    }

    // Test if fetching events handles errors correctly
    func testFetchEventsFailure() {
        mockNetworkService.shouldreturnError = true // Simulate an error
        mockEventsUseCase = MockEventsUseCase(networkManager: mockNetworkService)
        viewModel = EventsListViewModel(eventsUseCase: mockEventsUseCase, betsUseCase: mockBetsUseCase)

        let expectation = self.expectation(description: "Error handled")

        viewModel.errorSubject
            .subscribe(onNext: { errorMessage in
                XCTAssertEqual(errorMessage, "The operation couldn’t be completed. (Mock error error 0.)", "Error should be handled correctly")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        viewModel.fetchEvents()
        waitForExpectations(timeout: 2, handler: nil)
    }

    // Test if the filter works for events
    func testFilterEvents() {
        viewModel.events.accept([
            BetEvent.mock(id: "1", homeTeam: "Home 1", awayTeam: "Away 1"),
            BetEvent.mock(id: "2", homeTeam: "Home 2", awayTeam: "Away 2")
        ])

        let filteredEvents = viewModel.filterEvents(for: "Home 1")
        XCTAssertEqual(filteredEvents.count, 1, "There should be only 1 event after filtering")
        XCTAssertEqual(filteredEvents.first?.homeTeam, "Home 1", "Filtered event should match the search criteria")
    }

    // Test placing a bet
    func testPlaceBet() {
        let event = BetEvent.mock(id: "1", homeTeam: "Home Team", awayTeam: "Away Team")
        let odd = DisplayOutcome(label: .home, teamName: "Home Team", price: 1.5)

        viewModel.placeBet(for: event, with: odd)

        let placedBet = mockBetsUseCase.getBetForEvent(id: event.id)
        XCTAssertNotNil(placedBet, "Bet should be placed")
        XCTAssertEqual(placedBet?.odd.price, odd.price, "Bet price should match")
    }

    // Test removing a bet
    func testRemoveBet() {
        let event = BetEvent.mock(id: "1", homeTeam: "Home Team", awayTeam: "Away Team")
        let odd = DisplayOutcome(label: .home, teamName: "Home Team", price: 1.5)

        viewModel.placeBet(for: event, with: odd)
        viewModel.removeBet(for: event.id)

        let removedBet = mockBetsUseCase.getBetForEvent(id: event.id)
        XCTAssertNil(removedBet, "Bet should be removed")
    }
}
