import EventKit

struct CKCalendar {
    let identifier: String
    let title: String
    let color: CGColor
    let type: EKCalendarType
    
    init(_ calendar: EKCalendar) {
        identifier = calendar.calendarIdentifier
        title = calendar.title
        color = calendar.cgColor
        type = calendar.type
    }
}
