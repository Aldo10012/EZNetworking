import Foundation
import Testing

@Suite("Expectation Tests")
struct ExpectationTests {
    // MARK: - Basic Fulfillment Tests

    @Test("Expectation is fulfilled immediately")
    func expectation_fulfilledImmediately_succeeds() async {
        let expectation = Expectation()
        expectation.fulfill()
        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation is fulfilled after async work")
    func expectation_fulfilledAfterAsyncWork_succeeds() async {
        let expectation = Expectation()

        Task {
            try? await Task.sleep(for: .milliseconds(100))
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation not fulfilled within timeout records issue", .disabled())
    func expectation_notFulfilledWithinTimeout_recordsIssue() async {
        await withKnownIssue {
            let expectation = Expectation()
            // Never fulfill the expectation
            await expectation.fulfillment(within: .milliseconds(100))
        } matching: { issue in
            issue.description.contains("Expectation was not fulfilled")
        }
    }

    @Test("Expectation fulfilled multiple times within timeout")
    func expectation_fulfilledMultipleTimes_succeeds() async {
        let expectation = Expectation()

        Task {
            expectation.fulfill()
            expectation.fulfill()
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: - Expected Fulfillment Count Tests

    @Test("Expectation with count of 3 fulfilled 3 times succeeds")
    func expectation_withCount3_fulfilled3Times_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 3)

        Task {
            expectation.fulfill()
            expectation.fulfill()
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation with count of 3 fulfilled only 2 times records issue", .disabled())
    func expectation_withCount3_fulfilled2Times_recordsIssue() async {
        await withKnownIssue {
            let expectation = Expectation(expectedFulfillmentCount: 3)

            Task {
                expectation.fulfill()
                expectation.fulfill()
                // Only fulfilled 2 times, expected 3
            }

            await expectation.fulfillment(within: .seconds(1))
        } matching: { issue in
            issue.description.contains("Fulfilled 2/3 times")
        }
    }

    @Test("Expectation with count of 5 fulfilled 5 times succeeds")
    func expectation_withCount5_fulfilled5Times_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 5)

        Task {
            for _ in 0 ..< 5 {
                expectation.fulfill()
            }
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation with count of 2 fulfilled over time succeeds")
    func expectation_withCount2_fulfilledOverTime_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 2)

        Task {
            expectation.fulfill()
            try? await Task.sleep(for: .milliseconds(50))
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation with count of 1 not fulfilled records issue with correct count", .disabled())
    func expectation_withCount1_notFulfilled_recordsIssueWithCorrectCount() async {
        await withKnownIssue {
            let expectation = Expectation(expectedFulfillmentCount: 1)
            // Never fulfill
            await expectation.fulfillment(within: .milliseconds(100))
        } matching: { issue in
            issue.description.contains("Fulfilled 0/1 times")
        }
    }

    // MARK: - Inverted Expectation Tests

    @Test("Inverted expectation not fulfilled succeeds", .disabled())
    func invertedExpectation_notFulfilled_succeeds() async {
        let expectation = Expectation(isInverted: true)
        // Don't fulfill the expectation
        await expectation.fulfillment(within: .milliseconds(100))
    }

    @Test("Inverted expectation fulfilled records issue")
    func invertedExpectation_fulfilled_recordsIssue() async {
        await withKnownIssue {
            let expectation = Expectation(isInverted: true)
            expectation.fulfill()
            await expectation.fulfillment(within: .milliseconds(100))
        } matching: { issue in
            issue.description.contains("Inverted expectation was fulfilled")
        }
    }

    @Test("Inverted expectation with count 2 fulfilled once succeeds", .disabled())
    func invertedExpectation_withCount2_fulfilled1Time_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 2, isInverted: true)

        Task {
            expectation.fulfill()
            // Only fulfilled once, needed 2 to trigger inverted failure
        }

        await expectation.fulfillment(within: .milliseconds(100))
    }

    @Test("Inverted expectation with count 2 fulfilled 2 times records issue")
    func invertedExpectation_withCount2_fulfilled2Times_recordsIssue() async {
        await withKnownIssue {
            let expectation = Expectation(expectedFulfillmentCount: 2, isInverted: true)

            Task {
                expectation.fulfill()
                expectation.fulfill()
            }

            await expectation.fulfillment(within: .milliseconds(100))
        } matching: { issue in
            issue.description.contains("Inverted expectation was fulfilled")
        }
    }

    // MARK: - Timeout Tests

    @Test("Expectation with short timeout fulfilled in time succeeds")
    func expectation_withShortTimeout_fulfilledInTime_succeeds() async {
        let expectation = Expectation()

        Task {
            try? await Task.sleep(for: .milliseconds(10))
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .milliseconds(100))
    }

    @Test("Expectation with long timeout fulfilled quickly succeeds")
    func expectation_withLongTimeout_fulfilledQuickly_succeeds() async {
        let expectation = Expectation()

        Task {
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(10))
    }

    @Test("Expectation timeout message includes duration", .disabled())
    func expectation_timeoutMessage_includesDuration() async {
        await withKnownIssue {
            let expectation = Expectation()
            await expectation.fulfillment(within: .milliseconds(50))
        } matching: { issue in
            issue.description.contains("50000000 nanoseconds") ||
                issue.description.contains("0.05") ||
                issue.description.contains("milliseconds")
        }
    }

    // MARK: - Concurrent Fulfillment Tests

    @Test("Expectation fulfilled from multiple concurrent tasks")
    func expectation_fulfilledFromMultipleConcurrentTasks_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 3)

        async let task1: Void = Task {
            try? await Task.sleep(for: .milliseconds(10))
            expectation.fulfill()
        }.value

        async let task2: Void = Task {
            try? await Task.sleep(for: .milliseconds(20))
            expectation.fulfill()
        }.value

        async let task3: Void = Task {
            try? await Task.sleep(for: .milliseconds(30))
            expectation.fulfill()
        }.value

        _ = await (task1, task2, task3)

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Multiple expectations in same test all succeed")
    func multipleExpectations_allFulfilled_succeed() async {
        let expectation1 = Expectation()
        let expectation2 = Expectation()
        let expectation3 = Expectation()

        Task {
            expectation1.fulfill()
            try? await Task.sleep(for: .milliseconds(10))
            expectation2.fulfill()
            try? await Task.sleep(for: .milliseconds(10))
            expectation3.fulfill()
        }

        await expectation1.fulfillment(within: .seconds(1))
        await expectation2.fulfillment(within: .seconds(1))
        await expectation3.fulfillment(within: .seconds(1))
    }

    // MARK: - Real-world Scenario Tests

    @Test("Expectation with callback-based async operation")
    func expectation_withCallbackBasedOperation_succeeds() async {
        let expectation = Expectation()

        performAsyncOperation { result in
            defer { expectation.fulfill() }
            #expect(result == "Success")
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation with multiple callbacks verifies all are called")
    func expectation_withMultipleCallbacks_verifiesAllCalled() async {
        let expectation = Expectation(expectedFulfillmentCount: 3)
        var callbackResults: [String] = []

        performMultipleCallbacks { result in
            callbackResults.append(result)
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
        #expect(callbackResults.count == 3)
    }

    @Test("Expectation with delegate pattern")
    func expectation_withDelegatePattern_succeeds() async {
        let expectation = Expectation()
        let delegate = MockDelegate {
            expectation.fulfill()
        }

        let worker = AsyncWorker()
        worker.delegate = delegate
        worker.start()

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation with closure-based completion handler")
    func expectation_withCompletionHandler_succeeds() async {
        let expectation = Expectation()

        fetchData { data, error in
            defer { expectation.fulfill() }
            #expect(error == nil)
            #expect(data != nil)
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    // MARK: - Edge Cases

    @Test("Expectation fulfilled more times than expected still succeeds")
    func expectation_fulfilledMoreThanExpected_succeeds() async {
        let expectation = Expectation(expectedFulfillmentCount: 2)

        Task {
            expectation.fulfill()
            expectation.fulfill()
            expectation.fulfill()
            expectation.fulfill()
        }

        await expectation.fulfillment(within: .seconds(1))
    }

    @Test("Expectation can be reused after awaiting fulfillment")
    func expectation_canBeReused_afterAwaitingFulfillment() async {
        let expectation = Expectation()

        // First use
        Task {
            expectation.fulfill()
        }
        await expectation.fulfillment(within: .seconds(1))

        // Note: Reusing expectations is generally not recommended,
        // but technically the fulfill can be called again
        Task {
            try? await Task.sleep(for: .milliseconds(10))
            expectation.fulfill()
        }

        // The second fulfillment will happen but won't be waited on
        // This test just ensures no crashes occur
    }
}

// MARK: - Helper Functions and Classes for Testing

private func performAsyncOperation(completion: @escaping (String) -> Void) {
    Task {
        try? await Task.sleep(for: .milliseconds(50))
        completion("Success")
    }
}

private func performMultipleCallbacks(completion: @escaping (String) -> Void) {
    Task {
        try? await Task.sleep(for: .milliseconds(20))
        completion("First")
        try? await Task.sleep(for: .milliseconds(20))
        completion("Second")
        try? await Task.sleep(for: .milliseconds(20))
        completion("Third")
    }
}

private func fetchData(completion: @escaping (String?, Error?) -> Void) {
    Task {
        try? await Task.sleep(for: .milliseconds(30))
        completion("Mock Data", nil)
    }
}

private protocol WorkerDelegate: AnyObject {
    func workerDidFinish()
}

private class MockDelegate: WorkerDelegate {
    let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func workerDidFinish() {
        onFinish()
    }
}

private class AsyncWorker {
    weak var delegate: WorkerDelegate?

    func start() {
        Task {
            try? await Task.sleep(for: .milliseconds(50))
            delegate?.workerDidFinish()
        }
    }
}
