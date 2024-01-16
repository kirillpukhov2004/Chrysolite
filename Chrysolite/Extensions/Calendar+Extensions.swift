import Foundation

extension Calendar {
    func getDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates = [Date]()

        dates.append(startDate)
        enumerateDates(startingAfter: startDate, matching: .init(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }

            dates.append(date)

            if isDate(endDate, inSameDayAs: date) {
                stop = true
            }
        }

        return dates
    }

    func startOfMonth(for date: Date) -> Date? {
        return self.date(from: dateComponents([.year, .month], from: date))
    }

    func endOfMonth(for date: Date) -> Date? {
        guard let startOfMonth = startOfMonth(for: date) else { return nil }

        return self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
    }
}
