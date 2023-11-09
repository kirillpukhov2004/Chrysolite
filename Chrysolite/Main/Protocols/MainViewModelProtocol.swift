import UIKit
import Combine
import DifferenceKit
import CalendarKit

protocol MainViewModelProtocol: AnyObject {
    var eventManager: EventManager { get }

    func calendarButtonPressedAction()

    func plusButtonPressedAction()

    var selectedDate: Date { get }

    var selectedDatePublisher: Published<Date>.Publisher { get }
}
