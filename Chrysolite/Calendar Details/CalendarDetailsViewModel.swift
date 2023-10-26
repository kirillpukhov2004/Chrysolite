import UIKit
import EventKit
import Combine
import OSLog

protocol CalendarDetailsViewModelProtocol: AnyObject {
    var calendarDetailsTableViewItem: CalendarDetailsTableViewItem { get }
}

class CalendarDetailsViewModel: CalendarDetailsViewModelProtocol {
    let eventManager: EventManager

    let calendar: EKCalendar
    
    var calendarDetailsTableViewItem: CalendarDetailsTableViewItem {
        CalendarDetailsTableViewItem(title: calendar.title,
                                     color: UIColor(cgColor: calendar.cgColor),
                                     sourceType: .init(source: calendar.source))

    }

    init(eventManager: EventManager, calendar: EKCalendar) {
        self.eventManager = eventManager
        
        self.calendar = calendar
    }
}
