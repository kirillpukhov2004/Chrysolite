import UIKit

typealias EventsTableViewDataType = [(section: EventsTableViewHeaderModel, items: [EventsTableViewCellModel])]

struct EventsTableViewHeaderModel: Hashable {
    let date: Date
    let weekDayText: String
    let dateLabelText: String
    
    // Standard Date Equatable conformance is wrong for this case
    static func == (lhs: EventsTableViewHeaderModel, rhs: EventsTableViewHeaderModel) -> Bool {
        return Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

struct EventsTableViewCellModel: Hashable {
    let eventIdentifier: String
    let title: String
    let calendarColor: UIColor
}
