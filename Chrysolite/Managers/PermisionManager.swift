import EventKit

class PermisionManager {}

extension PermisionManager {
    static var isFullAccessToEventsGranted: Bool {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }
    
    static func requestFullAccessToEvents(with eventStore: EKEventStore) async throws {
        if #available(iOS 17.0, *) {
            try await eventStore.requestFullAccessToEvents()
        } else {
            try await eventStore.requestAccess(to: .event)
        }
    }

    static var isWriteOnlyAceessToEventsGranted: Bool {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event) == .writeOnly
        } else {
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    static func requestWriteOnlyAcessToEvents(with eventStore: EKEventStore) async throws {
        if #available(iOS 17.0, *) {
            try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            try await eventStore.requestAccess(to: .event)
        }
    }
}

extension PermisionManager {
    static var isAccessToRemindersGranted: Bool {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
        } else {
            return EKEventStore.authorizationStatus(for: .reminder) == .authorized
        }
    }

    static func requestAccessToReminders(with eventStore: EKEventStore) async throws {
        if #available(iOS 17.0, *) {
            try await eventStore.requestFullAccessToReminders()
        } else {
            try await eventStore.requestAccess(to: .event)
        }
    }
}
