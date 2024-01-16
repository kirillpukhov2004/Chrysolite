import EventKit

protocol CalendarsFlowCoordinatorProtocol: Coordinator {
    func showDetails(for calendar: EKCalendar)
}
