import UIKit
import EventKit
import Combine
import DifferenceKit
import OSLog
import CalendarKit

class MainViewModel: MainViewModelProtocol {
    let coordinator: MainFlowCoordinatorProtocol
    
    let eventManager: EventManager
    
    var cancellables = Set<AnyCancellable>()

    @Published var selectedDate: Date
    
    var selectedDatePublisher: Published<Date>.Publisher {
        $selectedDate
    }
    
    init(coordinator: MainFlowCoordinatorProtocol, eventManager: EventManager) {
        self.coordinator = coordinator
        
        self.eventManager = eventManager

        selectedDate = Date()
    }
    
    // MARK: Actions
    
    func calendarButtonPressedAction() {
        coordinator.startCalendarsListFlow()
    }
    
    func plusButtonPressedAction() {}
    
//    // MARK: EventsTableView
//    
//    var eventsTableViewDataUpdatedSubject = PassthroughSubject<StagedChangeset<[EventsTableViewSection]>, Never>()
//    
//    var numberOfSectionsInEventsTableView: Int {
//        if showOnlyDaysWithEevents {
//            return eventsTableViewSections.count
//        } else {
//            return Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day!
//        }
//    }
//    
//    func eventsTableViewNumberOfRows(in section: Int) -> Int {
//        return getEvents(in: section).count
//    }
//    
//    func eventsTableViewCellSelectedAction(_ indexPath: IndexPath) {
//        let event = getEvent(for: indexPath)
//
////        coordinator.showDetails(for: event)
//    }
//    
//    func eventsTableViewTopHeaderDidChanged(to section: Int) {
//        let date = getDate(for: section)
//
//        selectedDate = date
//    }
//    
//    func eventsTableviewDidScrollToTop() {
//        let startOfTheCurrentYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: selectedDate))!
//        let startOfThePreviousYear = Calendar.current.date(byAdding: DateComponents(year: -1), to: startOfTheCurrentYear)!
//        
//        if startOfThePreviousYear < fromDate {
//            fromDate = startOfThePreviousYear
//        }
//        
//        updateEventSubscription()
//    }
//    
//    func eventsTableViewDidScrollToBottom() {
//        let startOfTheCurrentYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: selectedDate))!
//        let endOfTheNextYear = Calendar.current.date(byAdding: DateComponents(year: 2, day: -1), to: startOfTheCurrentYear)!
//        
//        if endOfTheNextYear > toDate {
//            toDate = endOfTheNextYear
//        }
//        
//        updateEventSubscription()
//    }
//    
//    // MARK: Utilities
//    
//    func getDate(for section: Int) -> Date {
//        let date: Date
//        
//        if showOnlyDaysWithEevents {
//            date = eventsTableViewSections[section].date
//        } else {
//            date = Calendar.current.date(byAdding: .day, value: section, to: fromDate)!
//        }
//        
//        return date
//    }
//    
//    func getEvents(in section: Int) -> [Event] {
//        if showOnlyDaysWithEevents {
//            let events = eventsTableViewSections[section].elements
//            
//            return events
//        } else {
//            let date = Calendar.current.date(byAdding: .day, value: section, to: fromDate)!
//            
//            if let events = eventsTableViewSections.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.elements {
//                return events
//            } else {
//                return []
//            }
//        }
//    }
//    
//    func getEvent(for indexPath: IndexPath) -> Event {
//        let events = getEvents(in: indexPath.section)
//        
//        return events[indexPath.row]
//    }
}
