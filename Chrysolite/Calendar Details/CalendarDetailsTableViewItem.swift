import UIKit
import EventKit

enum CalendarSourceType: String {
    case local = "Local"
    case external = "External"
    case birthdays = "Birthdays"

    init(source: EKSource) {
        switch source.sourceType {
        case .local:
            self = .local
        case .birthdays:
            self = .birthdays
        default:
            self = .external
        }
    }
}

struct CalendarDetailsTableViewItem {
    let title: String
    let color: UIColor
    let sourceType: CalendarSourceType
}
