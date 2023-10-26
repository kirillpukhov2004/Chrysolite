import UIKit
import EventKit
import Combine
import OSLog

class MainViewController: UIViewController {
    typealias EventsTableViewDiffableDataSourceType = UITableViewDiffableDataSource<EventsTableViewHeaderModel, EventsTableViewCellModel>

    private let viewModel: MainViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    var calendarBarButtonItem: UIBarButtonItem!
    var plusBarButtonItem: UIBarButtonItem!

    var calendarView: CalendarView!
    
    var eventsTableView: UITableView!
    private var eventsTableViewDiffableDataSource: EventsTableViewDiffableDataSourceType!
    
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        calendarBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonPressed))
        navigationItem.leftBarButtonItems = [calendarBarButtonItem]

        plusBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonPressed))
        navigationItem.rightBarButtonItems = [plusBarButtonItem]
        
        calendarView = CalendarView()
        view.addSubview(calendarView)

        eventsTableView = UITableView(frame: .zero, style: .plain)
        eventsTableView.register(EventsTableViewCell.self)
        eventsTableView.register(EventsTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: EventsTableViewHeaderView.identifier)
        eventsTableView.delegate = self
        eventsTableView.showsVerticalScrollIndicator = false
        eventsTableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            eventsTableView.sectionHeaderTopPadding = 11
        }
        view.addSubview(eventsTableView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            calendarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.425)
        ])
        
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            eventsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            eventsTableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        eventsTableViewDiffableDataSource = .init(
            tableView: eventsTableView,
            cellProvider: { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(EventsTableViewCell.self, for: indexPath)
                cell.configure(with: item)
                
                return cell
            }
        )
        
        viewModel.eventsTableViewDataSubject
            .sink { [weak self] data in
                guard let self = self else { fatalError() }
                
                var snapshot = NSDiffableDataSourceSnapshot<EventsTableViewHeaderModel, EventsTableViewCellModel>()
                
                snapshot.appendSections(data.map { $0.section })
                data.forEach { section, items in
                    snapshot.appendItems(items, toSection: section)
                }
                
                eventsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        let sections = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers
        guard let sectionIndex = sections.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) else { return }
        
        eventsTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: sectionIndex), at: .top, animated: true)
    }

    // MARK: Selector Functions
    
    @objc private func calendarButtonPressed() {
        viewModel.calendarButtonPressedAction()
    }

    @objc private func plusButtonPressed() {
        viewModel.plusButtonPressedAction()
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(EventsTableViewHeaderView.self)
        
        let section = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers[section]
        header.configure(with: section)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let eventIdentifier = eventsTableViewDiffableDataSource.itemIdentifier(for: indexPath)?.eventIdentifier else { return }
        
        viewModel.eventSelectedAction(eventIdentifier: eventIdentifier)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let section = eventsTableView.indexesOfVisibleSections.first else { return }
        
        let date = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers[section].date
        
        calendarView.selectedDate = date
        
//        updateRanges(for: date)
    }
    
    private func updateRanges(for date: Date) {
        guard let firstCachedDate = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers.first?.date,
              let lastCachedDate = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers.last?.date
        else { return }
        
        if Calendar.current.isDate(firstCachedDate, equalTo: date, toGranularity: .month) {
            viewModel.updateRanges(for: date)
        } else if Calendar.current.isDate(lastCachedDate, equalTo: date, toGranularity: .month) {
            viewModel.updateRanges(for: date)
        }
    }
}
