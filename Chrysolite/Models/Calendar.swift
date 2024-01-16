import EventKit

struct Calendar {
    let identifier: String
    let title: String
    let color: CGColor
    let type: EKCalendarType
}

extension Calendar {
    init(ekCalendar calendar: EKCalendar) {
        identifier = calendar.calendarIdentifier
        title = calendar.title
        color = calendar.cgColor
        type = calendar.type
    }
}
