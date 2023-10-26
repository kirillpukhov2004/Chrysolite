import UIKit
import EventKit
import Combine
import OSLog

enum CalendarDetailsFields: CaseIterable {
    case title
    case color
    case sourceType
}

class CalendarDetailsViewController: UIViewController {
    let viewModel: CalendarDetailsViewModelProtocol

    var editBarButtonItem: UIBarButtonItem!

    var tableView: UITableView!

    init(viewModel: CalendarDetailsViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        configureViews()
        addSubviews()
        setupConstraints()
    }

    func configureViews() {
        view.backgroundColor = .systemBackground

        editBarButtonItem = UIBarButtonItem(
            systemItem: .edit,
            primaryAction: UIAction { [weak self] _ in
                self?.isEditing.toggle()
            }
        )

        tableView = UITableView(frame: .zero, style: .plain)

        tableView.register(CalendarDetailsTitleFieldTableViewCell.self,
                           forCellReuseIdentifier: CalendarDetailsTitleFieldTableViewCell.identifier)
        tableView.register(CalendarDetailsColorFieldTableViewCell.self,
                           forCellReuseIdentifier: CalendarDetailsColorFieldTableViewCell.identifier)
        tableView.register(CalendarDetailsSourceFieldTableViewCell.self,
                           forCellReuseIdentifier: CalendarDetailsSourceFieldTableViewCell.identifier)

        tableView.dataSource = self
    }

    func addSubviews() {
        navigationItem.rightBarButtonItems = [editBarButtonItem]

        view.addSubview(tableView)
    }

    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension CalendarDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CalendarDetailsFields.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CalendarDetailsFields.allCases[indexPath.row] {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarDetailsTitleFieldTableViewCell.identifier,
                                                     for: indexPath) as? CalendarDetailsTitleFieldTableViewCell
            guard let cell = cell else { fatalError() }

            cell.configure(with: viewModel.calendarDetailsTableViewItem)

            return cell
        case .color:
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarDetailsColorFieldTableViewCell.identifier,
                                                     for: indexPath) as? CalendarDetailsColorFieldTableViewCell
            guard let cell = cell else { fatalError() }

            cell.configure(with: viewModel.calendarDetailsTableViewItem)

            return cell
        case .sourceType:
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarDetailsSourceFieldTableViewCell.identifier,
                                                     for: indexPath) as? CalendarDetailsSourceFieldTableViewCell
            guard let cell = cell else { fatalError() }

            cell.configure(with: viewModel.calendarDetailsTableViewItem)

            return cell
        }
    }
}
