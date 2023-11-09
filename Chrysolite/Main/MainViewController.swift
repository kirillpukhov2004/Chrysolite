import UIKit
import EventKit
import Combine
import OSLog
import DifferenceKit

class MainViewController: UIViewController {
    let viewModel: MainViewModelProtocol

    var cancellables = Set<AnyCancellable>()

    var calendarBarButtonItem: UIBarButtonItem!
    var plusBarButtonItem: UIBarButtonItem!

    var dateStackView: UIStackView!

    var monthLabel: UILabel!

    var yearLabel: UILabel!

    var calendarView: CalendarView!

    var eventsListView: EventsListView!

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

        eventsListView = EventsListView(eventManager: viewModel.eventManager)
        view.addSubview(eventsListView)

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

        eventsListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventsListView.leftAnchor.constraint(equalTo: view.leftAnchor),
            eventsListView.rightAnchor.constraint(equalTo: view.rightAnchor),
            eventsListView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
            eventsListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    }

    override func viewDidAppear(_ animated: Bool) {
        calendarView.selectedDate = viewModel.selectedDate
    }

    // MARK: Selector Functions

    @objc private func calendarButtonPressed() {
        viewModel.calendarButtonPressedAction()
    }

    @objc private func plusButtonPressed() {
        viewModel.plusButtonPressedAction()
    }
}
