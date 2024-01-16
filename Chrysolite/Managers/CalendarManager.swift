import EventKit
import Combine
import OSLog

enum CalendarManagerError: Error {
    case calendarNotFound
}

class CalendarManager {
    let eventStore: EKEventStore
    
    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
    }
    
    func calendarsIdentifiersPublisher() -> AnyPublisher<[String], Never> {
        eventStore.eventStoreChangedPublisher
            .map { [weak self] in
                guard let self = self else { return [String]() }

                let calendars = eventStore.calendars(for: .event)
                let calendarsIdentifiers = calendars.compactMap { $0.calendarIdentifier }

                return calendarsIdentifiers
            }
            .eraseToAnyPublisher()
    }

    func calendar(with calendarIdentifier: String) throws -> EKCalendar {
        guard let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) else {
            throw CalendarManagerError.calendarNotFound
        }

        return calendar
    }
}
