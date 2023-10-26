import UIKit
import EventKit
import Combine
import OSLog

protocol EventDetailsViewModelProtocol: AnyObject {
    var eventDetailsTableViewItem: EventDetailsTableViewItem { get }
}

class EventDetailsViewModel: EventDetailsViewModelProtocol {
    let eventManager: EventManager
    
    var eventDetailsTableViewItem: EventDetailsTableViewItem
    
    var event: EKEvent
    
    init(event: EKEvent, eventManager: EventManager) {
        self.event = event
        self.eventManager = eventManager
        
        eventDetailsTableViewItem = EventDetailsTableViewItem(title: event.title)
    }
}
//protocol EventCreationViewModelProtocol: AnyObject {
//    var coreDataManager: CoreDataManager { get }
//
//    var title: String { get }
//    var titlePublisher: Published<String>.Publisher { get set }
//
//    var date: Date { get }
//    var datePublisher: Published<Date>.Publisher { get set }
//
//    func doneButtonPressed()
//
//    func cancelButtonPressed()
//}
//
//class EventCreationViewModel: ObservableObject, EventCreationViewModelProtocol {
//    let coreDataManager: CoreDataManager
//
//    var cancellables: Set<AnyCancellable> = Set()
//
//    @Published var title: String = ""
//    var titlePublisher: Published<String>.Publisher {
//        get {
//            $title
//        }
//
//        set {
//            $title = newValue
//        }
//    }
//
//    @Published var date: Date = Date()
//    var datePublisher: Published<Date>.Publisher {
//        get {
//            $date
//        }
//
//        set {
//            $date = newValue
//        }
//    }
//
//    init(coreDataManager: CoreDataManager) {
//        self.coreDataManager = coreDataManager
//    }
//
//    func doneButtonPressed() {
//    }
//
//    func cancelButtonPressed() {
//    }
//}
