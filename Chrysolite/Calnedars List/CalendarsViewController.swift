import UIKit
import Combine
import OSLog

class CalendarsViewController: UIViewController {
    typealias CalendarsTableViewDataSourceType = UITableViewDiffableDataSource<String, String>
    
    let viewModel: CalendarsViewModelProtocol
    
    var cancellables = Set<AnyCancellable>()

    var doneBarButtonItem: UIBarButtonItem!

    var calendarsTableView: UITableView!

    var calendarsTableViewDiffableDataSource: CalendarsTableViewDataSourceType!

    init(viewModel: CalendarsViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.rightBarButtonItems = [doneBarButtonItem]

        calendarsTableView = UITableView(frame: .zero, style: .plain)
        calendarsTableView.register(CalendarsTableViewCell.self)
        calendarsTableView.delegate = self
        view.addSubview(calendarsTableView)
        
        calendarsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            calendarsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            calendarsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            calendarsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        calendarsTableViewDiffableDataSource = CalendarsTableViewDataSourceType(tableView: calendarsTableView) { [weak self] tableView, indexPath, calendarIdentifier in
            guard let self = self else { return .init() }
            
            let cell = tableView.dequeueReusableCell(CalendarsTableViewCell.self, for: indexPath)
            
            let item = viewModel.calendarsTableViewItem(with: calendarIdentifier)
            cell.configureCell(for: item)
            
            return cell
        }

        viewModel.calendarsIdentifiersPublisher
            .sink { [weak self] calendarsIdentifiers in
                guard let self = self else { return }

                var snapshot = NSDiffableDataSourceSnapshot<String, String>()
                snapshot.appendSections(["Calendars"])
                snapshot.appendItems(calendarsIdentifiers)

                calendarsTableViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }

    @objc func doneButtonPressed() {
        dismiss(animated: true)
    }
}

extension CalendarsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let calendarIdentifier = calendarsTableViewDiffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        viewModel.calendarSelectedAction(calendarIdentifier: calendarIdentifier)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
