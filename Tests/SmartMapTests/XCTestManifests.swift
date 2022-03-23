import XCTest

#if !canImport(ObjectiveC)
/// Все тесты CallDetailsMetrics.
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CallDetailsMetricsTests.allTests)
    ]
}
#endif
