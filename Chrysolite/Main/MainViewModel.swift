import UIKit
import EventKit
import Combine
import OSLog

protocol MainViewModelProtocol: AnyObject {
    func calendarButtonPressedAction()
    
    func plusButtonPressedAction()
    
    var selectedDate: Date { get }
    
    var selectedDatePublisher: Published<Date>.Publisher { get }
    
    // EventsTableView
    
    var eventsTableViewDataUpdatedSubject: PassthroughSubject<Void, Never> { get }
    
    var numberOfSectionsInEventsTableView: Int { get }
    
    func newIndexPath() -> IndexPath
    
    func numberOfRowsInEventsTableView(for section: Int) -> Int
    
    func eventsTableViewCellModel(for indexPath: IndexPath) -> EventsTableViewCellModel
    
    func eventsTableViewHeaderModel(for section: Int) -> EventsTableViewHeaderModel
    
    func eventTableViewCellSelectedAction(_ indexPath: IndexPath)
    
    func eventTableViewTopHeaderDidChanged(to section: Int)
    
    func eventTableviewDidScrollToTop()
    
    func eventTableViewDidScrollToBottom()
}

class MainViewModel: MainViewModelProtocol {
    let coordinator: MainFlowCoordinatorProtocol
    
    let eventManager: EventManager
    
    var cancellables = Set<AnyCancellable>()

    @Published var selectedDate: Date
    
    var selectedDatePublisher: Published<Date>.Publisher {
        $selectedDate
    }
    
    var firstDate: Date
    var lastDate: Date
    
    var eventSubscription: AnyCancellable?
    var groupedEvents = [(Date, [EKEvent])]()
    
    var showOnlyDaysWithEevents: Bool = false
    
    init(coordinator: MainFlowCoordinatorProtocol, eventManager: EventManager) {
        self.coordinator = coordinator
        
        self.eventManager = eventManager
        
        let selectedDate = Date()
        self.selectedDate = selectedDate
        firstDate = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: selectedDate))!
        lastDate = Calendar.current.date(byAdding: .init(year: 1, day: -1), to: firstDate)!
        
        eventsTableViewDataUpdatedSubject = PassthroughSubject<Void, Never>()
        
        updateEventSubscription()
    }
    
    func calendarButtonPressedAction() {
        coordinator.startCalendarsListFlow()
    }
    
    func plusButtonPressedAction() {}
    
//    func updatePublisher(startDate: Date, endDate: Date) {
//        let weekDayFormatter = DateFormatter()
//        weekDayFormatter.dateFormat = "EEEE"
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .none
//        
//        var tableViewData = EventsTableViewDataType()
//        
//        if let eventsPublisher = eventsPublisher { eventsPublisher.cancel() }
//        
//        eventsPublisher = eventManager.eventPublisher(startDate: startDate, endDate: endDate)
//            .map { events in
//                var tableViewDataDict = [EventsTableViewHeaderModel: [EventsTableViewCellModel]]()
//                
//                events.forEach { event in
//                    let date = Calendar.current.startOfDay(for: event.startDate)
//                    
//                    let sectionModel = EventsTableViewHeaderModel(
//                        date: date,
//                        weekDayText: weekDayFormatter.string(from: date),
//                        dateLabelText: dateFormatter.string(from: date)
//                    )
//                    
//                    let cellModel = EventsTableViewCellModel(
//                        date: date,
//                        eventIdentifier: event.eventIdentifier,
//                        title: event.title,
//                        calendarColor: UIColor(cgColor: event.calendar.cgColor)
//                    )
//                    
//                    if tableViewDataDict.keys.contains(sectionModel) {
//                        tableViewDataDict[sectionModel]?.append(cellModel)
//                    } else {
//                        tableViewDataDict[sectionModel] = [cellModel]
//                    }
//                }
//                
//                var tableViewData = tableViewData
//                
//                tableViewDataDict.forEach { section, items in
//                    guard let index = tableViewData.firstIndex(where: { $0.section == section }) else { return }
//                    
//                    tableViewData[index] = (section: section, items: items)
//                }
//                
//                return tableViewData
//            }
//            .subscribe(eventsTableViewDataSubject)
//    }

//    func updateRanges(for date: Date) {
//        let startOfTheYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: date))!
//        let endOfTheYear = Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: startOfTheYear)!
//        
//        if startDate == nil || endDate == nil {
//            startDate = startOfTheYear
//            endDate = endOfTheYear
//        } else if startDate! < startOfTheYear && endDate! < endOfTheYear {
//            endDate = endOfTheYear
//        } else if startDate! > startOfTheYear && endDate! > endOfTheYear {
//            startDate = startOfTheYear
//        }
//        
//        updatePublisher(startDate: startDate!, endDate: endDate!)
//        
//        if #available(iOS 15.0, *) {
//            p(startDate!.formatted(date: .long, time: .omitted), endDate!.formatted(date: .long, time: .omitted))
//        }
//    }
    
    func updateEventSubscription() {
        if let eventSubscription = eventSubscription { eventSubscription.cancel() }
        
        eventSubscription = eventManager.eventPublisher(startDate: firstDate, endDate: lastDate)
            .sink { [weak self] events in
                let gruopedEventsDictionary = Dictionary(grouping: events, by: { Calendar.current.startOfDay(for: $0.startDate) })
                
                self?.groupedEvents = gruopedEventsDictionary.sorted { $0.key < $1.key }
            }
    }
    
    // MARK: EventsTableView
    
    var eventsTableViewDataUpdatedSubject: PassthroughSubject<Void, Never>
    
    var numberOfSectionsInEventsTableView: Int {
        if showOnlyDaysWithEevents {
            return groupedEvents.count
        } else {
            return Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day!
        }
    }
    
    func newIndexPath() -> IndexPath {
        if showOnlyDaysWithEevents {
            fatalError()
        } else {
            let section = Calendar.current.dateComponents([.day], from: firstDate, to: selectedDate).day!
            
            return IndexPath(row: NSNotFound, section: section)
        }
    }
    
    func numberOfRowsInEventsTableView(for section: Int) -> Int {
        getEvents(in: section).count
    }
    
    func eventsTableViewCellModel(for indexPath: IndexPath) -> EventsTableViewCellModel {
        let event = getEvent(for: indexPath)
        
        return EventsTableViewCellModel(date: event.startDate, eventIdentifier: event.eventIdentifier, title: event.title, calendarColor: UIColor(cgColor: event.calendar.cgColor))
    }
    
    func eventsTableViewHeaderModel(for section: Int) -> EventsTableViewHeaderModel {
        let date = getDate(for: section)

        let weekDayFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "EEEE"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return EventsTableViewHeaderModel(date: date, weekDayText: weekDayFormatter.string(from: date), dateLabelText: dateFormatter.string(from: date))
    }
    
    func eventTableViewCellSelectedAction(_ indexPath: IndexPath) {
        let event = getEvent(for: indexPath)

        coordinator.showDetails(for: event)
    }
    
    func eventTableViewTopHeaderDidChanged(to section: Int) {
        let date = getDate(for: section)

        selectedDate = date
    }
    
    func eventTableviewDidScrollToTop() {
        let startOfTheCurrentYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: selectedDate))!
        let startOfThePreviousYear = Calendar.current.date(byAdding: DateComponents(year: -1), to: startOfTheCurrentYear)!
        
        if startOfThePreviousYear < firstDate {
            firstDate = startOfThePreviousYear
        }
        
        updateEventSubscription()
        eventsTableViewDataUpdatedSubject.send()
    }
    
    func eventTableViewDidScrollToBottom() {
        let startOfTheCurrentYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: selectedDate))!
        let endOfTheNextYear = Calendar.current.date(byAdding: DateComponents(year: 2, day: -1), to: startOfTheCurrentYear)!
        
        if endOfTheNextYear > lastDate {
            lastDate = endOfTheNextYear
        }
        
        updateEventSubscription()
        eventsTableViewDataUpdatedSubject.send()
    }
    
    func getDate(for section: Int) -> Date {
        let date: Date
        
        if showOnlyDaysWithEevents {
            date = groupedEvents[section].0
        } else {
            date = Calendar.current.date(byAdding: .day, value: section, to: firstDate)!
        }
        
        return date
    }
    
    func getEvents(in section: Int) -> [EKEvent] {
        if showOnlyDaysWithEevents {
            let events = groupedEvents[section].1
            
            return events
        } else {
            let date = Calendar.current.date(byAdding: .day, value: section, to: firstDate)!
            
            if let events = groupedEvents.first(where: { Calendar.current.isDate($0.0, inSameDayAs: date) })?.1 {
                return events
            } else {
                return []
            }
        }
    }
    
    func getEvent(for indexPath: IndexPath) -> EKEvent {
        let events = getEvents(in: indexPath.section)
        
        return events[indexPath.row]
    }
}

extension Calendar {
    func getDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates = [Date]()
        
        dates.append(startDate)
        enumerateDates(startingAfter: startDate, matching: .init(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            
            dates.append(date)
            
            if isDate(endDate, inSameDayAs: date) {
                stop = true
            }
        }
        
        return dates
    }
}
