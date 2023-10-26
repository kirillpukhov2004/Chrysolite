import EventKit
import Combine
import OSLog

enum EventManagerError: Error {
    case eventNotFound
    case calendarNotFound
}

class EventManager {
    private let eventStore: EKEventStore

    var startDate = Date()
    var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!

    var eventStoreChangedPublisher: AnyPublisher<Void, Never>
    
    var cancellables = Set<AnyCancellable>()

    init(eventStore: EKEventStore) {
        self.eventStore = eventStore

        eventStoreChangedPublisher = eventStore.eventStoreChangedPublisher
    }
    
    func eventPublisher(startDate: Date, endDate: Date, calendars: [EKCalendar]? = nil) -> AnyPublisher<[EKEvent], Never> {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            
        let events = eventStore.events(matching: predicate)
        
        let subject = CurrentValueSubject<[EKEvent], Never>(events)
        
        eventStoreChangedPublisher
            .map { [weak self] in
                guard let self = self else { return [] }
                
                return eventStore.events(matching: predicate)
            }
            .subscribe(subject)
            .store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }
    
    func eventsIdentifiersPublisher(startDate: Date, endDate: Date, calendars: [EKCalendar]? = nil) -> AnyPublisher<[String], Never> {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)

        let publisher = eventStoreChangedPublisher
            .map { [weak self] in
                guard let self = self else { return [String]() }

                let events = eventStore.events(matching: predicate)
                let eventsIdentifiers = events.compactMap { $0.eventIdentifier }

                return eventsIdentifiers
            }
            .eraseToAnyPublisher()

        return publisher
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
