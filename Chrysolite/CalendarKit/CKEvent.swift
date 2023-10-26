import EventKit

struct CKEvent {
    let identifier: String
    let calendar: CKCalendar
    let title: String
    let notes: String
    let attendes: [EKParticipant]
    let alarms: [EKAlarm]
    let reccurenceRules: EKRecurrenceRule?
    
    init(_ event: EKEvent) {
        identifier = event.eventIdentifier
        calendar = CKCalendar(event.calendar)
        title = event.title
        notes = event.notes ?? ""
        attendes = event.attendees ?? []
        alarms = event.alarms ?? []
        reccurenceRules = event.recurrenceRules?.first
    }
}
