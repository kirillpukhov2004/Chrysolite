import UIKit
import EventKit

class CalendarDetailsViewModel: CalendarDetailsViewModelProtocol {
    let eventManager: EventManager

    let calendar: EKCalendar
    
    var calendarDetailsTableViewCellModel: CalendarDetailsTableViewCellModel

    init(calendar: EKCalendar, eventManager: EventManager) {
        self.eventManager = eventManager
        
        self.calendar = calendar
        
        calendarDetailsTableViewCellModel = CalendarDetailsTableViewCellModel(
            titleLabelText: calendar.title,
            calendarIndicatorColor: UIColor(cgColor: calendar.cgColor)
        )
    }
}
