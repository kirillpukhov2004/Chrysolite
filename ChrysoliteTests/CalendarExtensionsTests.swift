import XCTest
@testable import Chrysolite

final class CalendarExtensionTests: XCTestCase {
    func testStartOfMonth() {
        let calendar = Calendar.current

        let date = calendar.date(from: DateComponents(year: 2004, month: 2, day: 6))!

        let result = calendar.startOfMonth(for: date)!

        let reference = calendar.date(from: DateComponents(year: 2004, month: 2, day: 1))!

        XCTAssertEqual(result, reference)
    }

    func testEndOfMonth() {
        let calendar = Calendar.current

        let firstDate = calendar.date(from: DateComponents(year: 2004, month: 2, day: 6))!
        let firstResult = calendar.endOfMonth(for: firstDate)!
        let firstReference = calendar.date(from: DateComponents(year: 2004, month: 2, day: 29))!

        let secondDate = calendar.date(from: DateComponents(year: 1971, month: 1, day: 24))!
        let secondResult = calendar.endOfMonth(for: secondDate)!
        let secondReference = calendar.date(from: DateComponents(year: 1971, month: 1, day: 31))!

        XCTAssertEqual(firstResult, firstReference)
        XCTAssertEqual(secondResult, secondReference)
    }
}
