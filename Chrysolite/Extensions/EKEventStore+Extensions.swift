import EventKit
import Combine

extension EKEventStore {
    var eventStoreChangedPublisher: AnyPublisher<Void, Never> {
        let subject = CurrentValueSubject<Void, Never>(())
        
        _ = NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: self)
            .map { _ in () }
            .subscribe(subject)
            
        return subject.eraseToAnyPublisher()
    }
}
