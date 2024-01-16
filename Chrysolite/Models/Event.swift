import EventKit

struct Event {
    let identifier: String
    let calendar: Calendar
    let title: String
    let notes: String
    let startDate: Date
    let attendees: [EKParticipant]
    let alarms: [EKAlarm]
    let recurrenceRules: EKRecurrenceRule?
}

extension Event {
    init(ekEvent: EKEvent) {
        identifier = ekEvent.eventIdentifier
        calendar = Calendar(ekCalendar: ekEvent.calendar)
        title = ekEvent.title
        notes = ekEvent.notes ?? ""
        startDate = ekEvent.startDate
        attendees = ekEvent.attendees ?? []
        alarms = ekEvent.alarms ?? []
        recurrenceRules = ekEvent.recurrenceRules?.first
    }
}

extension Event: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(startDate)
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.startDate == rhs.startDate
    }
}
