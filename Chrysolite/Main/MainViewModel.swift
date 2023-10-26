import UIKit
import EventKit
import Combine
import OSLog

protocol MainViewModelProtocol: AnyObject {
    var eventsTableViewDataSubject: CurrentValueSubject<EventsTableViewDataType, Never> { get }
    
    func updateRanges(for date: Date)
    
    func eventSelectedAction(eventIdentifier: String)
    
    func calendarButtonPressedAction()
    
    func plusButtonPressedAction()
}


class MainViewModel: MainViewModelProtocol {
    let coordinator: MainFlowCoordinatorProtocol
    
    let eventManager: EventManager
    
    var cancellables = Set<AnyCancellable>()
    
    var eventsPublisher: AnyCancellable?
    var eventsTableViewDataSubject: CurrentValueSubject<EventsTableViewDataType, Never>
    
    init(coordinator: MainFlowCoordinatorProtocol, eventManager: EventManager) {
        self.coordinator = coordinator
        
        self.eventManager = eventManager
        
        eventsTableViewDataSubject = .init(.init())
        
        updateRanges(for: .init())
    }
    
    func eventSelectedAction(eventIdentifier: String) {
        guard let event = try? eventManager.event(with: eventIdentifier) else { return }
        
        coordinator.showDetails(for: event)
    }
    
    func calendarButtonPressedAction() {
        coordinator.startCalendarsListFlow()
    }
    
    func plusButtonPressedAction() {}
    
    func updatePublisher(startDate: Date, endDate: Date) {
        let weekDayFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "EEEE"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        var tableViewData = EventsTableViewDataType()
        
        Calendar.current.enumerateDates(
            startingAfter: Calendar.current.date(byAdding: .day, value: -1, to: startDate)!,
            matching: .init(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }
            
            let sectionModel = EventsTableViewHeaderModel(
                date: date,
                weekDayText: weekDayFormatter.string(from: date),
                dateLabelText: dateFormatter.string(from: date)
            )
            
            tableViewData.append((section: sectionModel, items: []))
            
            if Calendar.current.isDate(endDate, inSameDayAs: date) {
                stop = true
            }
        }
        
        if let eventsPublisher = eventsPublisher { eventsPublisher.cancel() }
        
        eventsPublisher = eventManager.eventPublisher(startDate: startDate, endDate: endDate)
            .map { events in
                var tableViewDataDict = [EventsTableViewHeaderModel: [EventsTableViewCellModel]]()
                
                events.forEach { event in
                    let date = Calendar.current.startOfDay(for: event.startDate)
                    
                    let sectionModel = EventsTableViewHeaderModel(
                        date: date,
                        weekDayText: weekDayFormatter.string(from: date),
                        dateLabelText: dateFormatter.string(from: date)
                    )
                    
                    let cellModel = EventsTableViewCellModel(
                        eventIdentifier: event.eventIdentifier,
                        title: event.title,
                        calendarColor: UIColor(cgColor: event.calendar.cgColor)
                    )
                    
                    if tableViewDataDict.keys.contains(sectionModel) {
                        tableViewDataDict[sectionModel]?.append(cellModel)
                    } else {
                        tableViewDataDict[sectionModel] = [cellModel]
                    }
                }
                
                var tableViewData = tableViewData
                
                tableViewDataDict.forEach { section, items in
                    guard let index = tableViewData.firstIndex(where: { $0.section == section }) else { return }
                    
                    tableViewData[index] = (section: section, items: items)
                }
                
                return tableViewData
            }
            .subscribe(eventsTableViewDataSubject)
    }
    
    func updateRanges(for date: Date) {
        let startOfTheYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
        let endOfTheYear = Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: startOfTheYear)!
        updatePublisher(startDate: startOfTheYear, endDate: endOfTheYear)
    }
}
