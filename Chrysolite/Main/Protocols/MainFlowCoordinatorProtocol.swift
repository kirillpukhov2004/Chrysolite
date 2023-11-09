import EventKit

protocol MainFlowCoordinatorProtocol: Coordinator {
    func startCalendarsListFlow()
    
    func showDetails(for event: EKEvent)
}
