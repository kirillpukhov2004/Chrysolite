import EventKit
import Combine

protocol CalendarsViewModelProtocol: AnyObject {
    var calendarsIdentifiersPublisher: AnyPublisher<[String], Never> { get }

    func calendarsTableViewItem(with calendarIdentifier: String) -> CalendarsTableViewCellModel

    func calendar(with calendarIdentifier: String) -> EKCalendar
    
    func calendarSelectedAction(calendarIdentifier: String)
}
