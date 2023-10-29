import UIKit
import EventKit
import Combine
import OSLog

class MainViewController: UIViewController {
    let viewModel: MainViewModelProtocol

    var cancellables = Set<AnyCancellable>()

    var calendarBarButtonItem: UIBarButtonItem!
    var plusBarButtonItem: UIBarButtonItem!
    
    var dateStackView: UIStackView!
    
    var monthLabel: UILabel!
    
    var yearLabel: UILabel!
    
    var calendarView: CalendarView!
    
    var eventsTableView: UITableView!
    
    var isUpdating: Bool = true
    
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
        
        dateStackView = UIStackView()
        dateStackView.axis = .horizontal
        dateStackView.distribution = .fill
        dateStackView.alignment = .bottom
        view.addSubview(dateStackView)
        
        monthLabel = UILabel()
        monthLabel.textColor = .label
        monthLabel.font = .systemFont(ofSize: 32, weight: .bold, design: .rounded)
        dateStackView.addArrangedSubview(monthLabel)
        
        yearLabel = UILabel()
        yearLabel.textColor = .label
        yearLabel.font = .systemFont(ofSize: 30, weight: .medium, design: .rounded)
        dateStackView.addArrangedSubview(yearLabel)
        
        calendarView = CalendarView()
        view.addSubview(calendarView)
        
        eventsTableView = UITableView(frame: .zero, style: .plain)
        eventsTableView.register(EventsTableViewCell.self)
        eventsTableView.register(EventsTableViewHeaderView.self)
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        eventsTableView.showsVerticalScrollIndicator = false
        eventsTableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            eventsTableView.sectionHeaderTopPadding = 11
        }
        view.addSubview(eventsTableView)
        
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dateStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        
        dateStackView.setCustomSpacing(8, after: monthLabel)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            calendarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            calendarView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor, multiplier: 0.75),
        ])
        
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            eventsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            eventsTableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        viewModel.selectedDatePublisher
            .sink { [weak self] date in
                guard let self = self else { return }
                
                calendarView.selectedDate = date
                
                let monthDateFormatter = DateFormatter()
                monthDateFormatter.dateFormat = "MMMM"
                
                let yearDateFormatter = DateFormatter()
                yearDateFormatter.dateFormat = "YYYY"
                
                monthLabel.text = monthDateFormatter.string(from: viewModel.selectedDate)
                yearLabel.text = yearDateFormatter.string(from: viewModel.selectedDate)
            }
            .store(in: &cancellables)
        
        viewModel.eventsTableViewDataUpdatedSubject
            .sink { [weak self] in
                guard let self = self else { return }
                
                let beforeNumberOfSections = eventsTableView.numberOfSections
                let beforeOffset = eventsTableView.contentOffset

                isUpdating = true

                eventsTableView.reloadData()
                
                if max(0, beforeOffset.y) == 0 {
                    let afterNumberOfSections = eventsTableView.numberOfSections
                    
                    let newContentOffset = eventsTableView.rectForHeader(inSection: afterNumberOfSections - beforeNumberOfSections).origin
                    
                    eventsTableView.setContentOffset(newContentOffset, animated: false)
                } else {
                    let afterOffset = eventsTableView.contentOffset
                
                    let newContentOffset = CGPoint(x: afterOffset.x - beforeOffset.x, y: afterOffset.y - afterOffset.x)
                    
                    eventsTableView.setContentOffset(newContentOffset, animated: false)
                }
                
                isUpdating = false
            }
            .store(in: &cancellables)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isUpdating = false
        calendarView.selectedDate = viewModel.selectedDate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Selector Functions
    
    @objc private func calendarButtonPressed() {
        viewModel.calendarButtonPressedAction()
    }

    @objc private func plusButtonPressed() {
        viewModel.plusButtonPressedAction()
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === eventsTableView {
            return viewModel.numberOfSectionsInEventsTableView
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === eventsTableView {
            return viewModel.numberOfRowsInEventsTableView(for: section)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(EventsTableViewCell.self, for: indexPath)
        
        let cellModel = viewModel.eventsTableViewCellModel(for: indexPath)
        cell.configure(with: cellModel)
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(EventsTableViewHeaderView.self)
        
        let headerModel = viewModel.eventsTableViewHeaderModel(for: section)
        header.configure(with: headerModel)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.eventTableViewCellSelectedAction(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let section = eventsTableView.indexesOfVisibleSections.first else { return }
        
        if !isUpdating {
            viewModel.eventTableViewTopHeaderDidChanged(to: section)
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            if offsetY <= 0 {
                viewModel.eventTableviewDidScrollToTop()
            } else if offsetY > contentHeight - screenHeight {
                viewModel.eventTableViewDidScrollToBottom()
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if tableView.numberOfSections == section + 1 {
//            guard let firstDate = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers.first?.date else { return }
//            guard let lastDate = eventsTableViewDiffableDataSource.snapshot().sectionIdentifiers.last?.date else { return }
//            
//            let date = calendarView.selectedDate!
//            
//            if Calendar.current.isDate(date, equalTo: firstDate, toGranularity: .month), Calendar.current.isDate(date, equalTo: firstDate, toGranularity: .year) {
//                viewModel.updateRanges(for: Calendar.current.date(byAdding: .year, value: -1, to: date)!)
//            } else if Calendar.current.isDate(date, equalTo: lastDate, toGranularity: .month), Calendar.current.isDate(date, equalTo: lastDate, toGranularity: .year) {
//                viewModel.updateRanges(for: Calendar.current.date(byAdding: .year, value: 1, to: date)!)
//            }
//        }
//    }
}
