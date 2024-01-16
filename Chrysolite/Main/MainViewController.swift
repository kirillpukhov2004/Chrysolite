import UIKit
import EventKit
import Combine
import OSLog
import DifferenceKit
import SnapKit

final class MainViewController: UIViewController {
    private let viewModel: MainViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    private var calendarBarButtonItem: UIBarButtonItem!

    private var plusBarButtonItem: UIBarButtonItem!

    private var dateStackView: UIStackView!

    private var monthLabel: UILabel!

    private var yearLabel: UILabel!

    private var calendarView: CalendarView!

    private var eventsListView: EventsListView!

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

        setupSubviews()
        setupLayoutConstraints()
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

    // MARK: Private Functions

    private func setupSubviews() {
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

        dateStackView.setCustomSpacing(8, after: monthLabel)
    }

    private func setupLayoutConstraints() {
        dateStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        calendarView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(monthLabel.snp.bottom).offset(10)
            make.height.equalTo(calendarView.snp.width).multipliedBy(0.75)
        }

        eventsListView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(calendarView.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: Selector Functions

    @objc private func calendarButtonPressed() {
        viewModel.calendarButtonPressedAction()
    }

    @objc private func plusButtonPressed() {
        viewModel.plusButtonPressedAction()
    }
}
