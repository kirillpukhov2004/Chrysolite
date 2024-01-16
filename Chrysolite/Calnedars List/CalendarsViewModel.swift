import UIKit
import Combine
import EventKit
import OSLog

class CalendarsViewModel: CalendarsViewModelProtocol {
    let coordinator: CalendarsFlowCoordinatorProtocol
    
    let calendarManager: CalendarManager
    let eventManager: EventManager

    init(
        coordinator: CalendarsFlowCoordinatorProtocol,
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

    func calendarsTableViewItem(with calendarIdentifier: String) -> CalendarsTableViewCellModel {
        let item: CalendarsTableViewCellModel

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
