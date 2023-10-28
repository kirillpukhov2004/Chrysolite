import UIKit
import Combine

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
