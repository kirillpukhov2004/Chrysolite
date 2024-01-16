import OSLog
import UIKit
import Combine
import DifferenceKit

extension Date: Differentiable {}

extension Event: Differentiable {}

class EventsListView: UIView {
    typealias EventsListTableViewSection = ArraySection<Date, Event>


    private var eventManager: EventManager!


    private var tableViewSections = [EventsListTableViewSection]()


    private var cancellables = Set<AnyCancellable>()

    private var eventSubscription: AnyCancellable?

    private var isUpdating = false


    private var calendar = Foundation.Calendar.current

    private var topDate = Foundation.Calendar.current.startOfDay(for: Date())

    private var startDate: Date!

    private var endDate: Date!


    private var tableView: UITableView!


    init(eventManager: EventManager) {
        super.init(frame: .zero)

        self.eventManager = eventManager

        setupSubviews()
        setupLayoutConstraints()

        startDate = calendar.date(byAdding: .month, value: -1, to: calendar.startOfMonth(for: topDate)!)!
        endDate = calendar.date(byAdding: .month, value: 1, to: calendar.endOfMonth(for: topDate)!)!

        updateEventsList()

        let sectionIndex = tableViewSections.firstIndex { $0.model.timeIntervalSinceNow > 0 }!
        tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: sectionIndex), at: .top, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(EventsListTableViewCell.self)
        tableView.register(EventsListTableViewHeaderView.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 11
        }
        addSubview(tableView)
    }

    private func setupLayoutConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private enum Constants {
        static var minimumDate = Foundation.Calendar.current.date(from: DateComponents(year: 0, month: 1))

        static var maximumDate = Foundation.Calendar.current.date(from: DateComponents(year: 10000, month: 12, day: 31))
    }
}

extension EventsListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewSections[section].elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(EventsListTableViewCell.self, for: indexPath)

        let event = tableViewSections[indexPath.section].elements[indexPath.item]

        let cellModel = EventsListTableViewCellModel(
            date: event.startDate,
            eventIdentifier: event.identifier,
            title: event.title,
            calendarColor: UIColor(cgColor: event.calendar.color)
        )
        cell.configure(with: cellModel)

        return cell
    }
}

extension EventsListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(EventsListTableViewHeaderView.self)

        let date = tableViewSections[section].model

        let weekDayFormatter = DateFormatter()
        weekDayFormatter.dateFormat = "EEEE"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        let headerViewModel = EventsListTableViewHeaderViewModel(
            date: date,
            weekDayText: weekDayFormatter.string(from: date),
            dateLabelText: dateFormatter.string(from: date)
        )
        headerView.configure(with: headerViewModel)

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isUpdating {
            performUpdates {
                guard let sectionIndex = tableView.indexesOfVisibleSections.first else { return }

                topDate = tableViewSections[sectionIndex].model
                
//                print("Offset:", tableView.contentOffset.y)
                if tableView.contentOffset.y < 0 {
                    startDate = Foundation.Calendar.current.date(byAdding: .month, value: -3, to: startDate)!

                    let oldContentHeight = tableView.contentSize.height
                    let distanceFromOffset = oldContentHeight - tableView.contentOffset.y

                    updateEventsList()

                    let newContentHeight = tableView.contentSize.height
                    
                    performAsyncUpdates { [self] in
                        tableView.contentOffset = CGPoint(x: 0, y: newContentHeight - distanceFromOffset)
                    }

                } else if tableView.contentOffset.y > tableView.contentSize.height - tableView.frame.height {
                    endDate = Foundation.Calendar.current.date(byAdding: .month, value: 3, to: endDate)!

                    updateEventsList()
                }
            }
        }
    }
}

extension EventsListView {
    private func updateEventsList() {
        let ekEvents = eventManager.getEvents(from: startDate, to: endDate)

        let events = ekEvents.map { Event(ekEvent: $0) }
        let groupedEvents = Dictionary(grouping: events, by: { Calendar.current.startOfDay(for: $0.startDate) })
            .map { EventsListTableViewSection(model: $0.key, elements: $0.value) }
            .sorted { $0.model < $1.model }

        let stagedChanges = StagedChangeset(source: tableViewSections, target: groupedEvents)

        UIView.setAnimationsEnabled(false)

        tableView.reload(using: stagedChanges, with: .automatic) { self.tableViewSections = $0 }

        UIView.setAnimationsEnabled(true)
    }

    private func performUpdates(_ updatesClosure: () -> Void) {
            isUpdating = true

            updatesClosure()

            isUpdating = false
    }

    private func performAsyncUpdates(_ updatesClosure: @escaping () -> Void, _ completionHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async { [self] in
            performUpdates(updatesClosure)

            completionHandler?()
        }
    }
}
