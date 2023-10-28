import UIKit
import EventKit
import Combine
import OSLog

enum CalendarDetailsFields: CaseIterable {
    case title
    case color
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

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItems = [editBarButtonItem]

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CalendarDetailsTitleFieldTableViewCell.self)
        tableView.register(CalendarDetailsColorFieldTableViewCell.self)
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc func editButtonPressed() {
        isEditing.toggle()
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

            cell.configure(with: viewModel.calendarDetailsTableViewCellModel)

            return cell
        case .color:
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarDetailsColorFieldTableViewCell.identifier,
                                                     for: indexPath) as? CalendarDetailsColorFieldTableViewCell
            guard let cell = cell else { fatalError() }

            cell.configure(with: viewModel.calendarDetailsTableViewCellModel)

            return cell
        }
    }
}
