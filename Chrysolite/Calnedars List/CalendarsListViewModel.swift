import UIKit
import Combine
import EventKit
import OSLog

protocol CalendarsViewModelProtocol: AnyObject {
    var calendarsIdentifiersPublisher: AnyPublisher<[String], Never> { get }

    func calendarsTableViewItem(with calendarIdentifier: String) -> CalendarsListTableViewItem

    func calendar(with calendarIdentifier: String) -> EKCalendar
    
    func calendarSelectedAction(calendarIdentifier: String)
}

class CalendarsViewModel: CalendarsViewModelProtocol {
    let coordinator: CalendarsListFlowCoordinatorProtocol
    
    let calendarManager: CalendarManager
    let eventManager: EventManager

    init(
        coordinator: CalendarsListFlowCoordinatorProtocol,
        calendarManager: CalendarManager,
        eventManager: EventManager
    ) {
        self.coordinator = coordinator
        self.calendarManager = calendarManager
        self.eventManager = eventManager
    }

    var calendarsIdentifiersPublisher: AnyPublisher<[String], Never> {
        calendarManager.calendarsIdentifiersPublisher()
    }

    func calendarsTableViewItem(with calendarIdentifier: String) -> CalendarsListTableViewItem {
        let item: CalendarsListTableViewItem

        do {
            let calendar = try calendarManager.calendar(with: calendarIdentifier)
            item = .init(title: calendar.title,
                         color: UIColor(cgColor: calendar.cgColor))
        } catch {
            switch error {
            case CalendarManagerError.calendarNotFound:
                item = .init(title: "Event not found", color: .red)
            default:
                fatalError(error.localizedDescription)
            }
        }

        return item
    }

    func calendar(with calendarIdentifier: String) -> EKCalendar {
        do {
            let calendar = try calendarManager.calendar(with: calendarIdentifier)

            return calendar
        } catch {
            fatalError()
        }
    }
    
    func calendarSelectedAction(calendarIdentifier: String) {
        let calendar = try! calendarManager.calendar(with: calendarIdentifier)
        
        coordinator.showDetails(for: calendar)
    }
}
