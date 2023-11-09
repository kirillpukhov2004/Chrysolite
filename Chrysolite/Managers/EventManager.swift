import EventKit
import Combine
import OSLog

enum EventManagerError: Error {
    case eventNotFound
    case calendarNotFound
}

class EventManager {
    private let eventStore: EKEventStore

    var eventStoreChangedPublisher: AnyPublisher<Void, Never>
    
    var cancellables = Set<AnyCancellable>()

    init(eventStore: EKEventStore) {
        self.eventStore = eventStore

        eventStoreChangedPublisher = eventStore.eventStoreChangedPublisher
    }
    
    func eventPublisher(from startDate: Date, to endDate: Date, calendars: [EKCalendar]? = nil) -> AnyPublisher<[EKEvent], Never> {
        let events = getEvents(from: startDate, to: endDate)

        let subject = CurrentValueSubject<[EKEvent], Never>(events)
        
        eventStoreChangedPublisher
            .map { [weak self] in
                guard let self = self else { return [] }
                
                return getEvents(from: startDate, to: endDate)
            }
            .subscribe(subject)
            .store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }

    func getEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let calendar = Calendar.current

        var events = [EKEvent]()

        var currentDate = startDate
        while currentDate < endDate {
            let nextDate = calendar.date(byAdding: DateComponents(year: 4), to: currentDate)!

            let predicate: NSPredicate
            if nextDate > endDate {
                predicate = eventStore.predicateForEvents(
                    withStart: currentDate,
                    end: endDate,
                    calendars: calendars
                )

                currentDate = endDate
            } else {
                predicate = eventStore.predicateForEvents(
                    withStart: currentDate,
                    end: nextDate,
                    calendars: calendars
                )

                currentDate = nextDate
            }

            events.append(contentsOf: eventStore.events(matching: predicate))
        }

        return events
    }

    func event(with eventIdentifier: String) throws -> EKEvent {
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            throw EventManagerError.eventNotFound
        }

        return event
    }

    func deleteEvent(with eventIdentifier: String, span: EKSpan) throws {
        let event = try event(with: eventIdentifier)

        try eventStore.remove(event, span: span)
        try eventStore.commit()
    }
}
