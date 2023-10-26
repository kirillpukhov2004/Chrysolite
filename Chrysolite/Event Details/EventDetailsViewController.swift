import UIKit
import Combine
import OSLog

enum EventDetailsTableViewFields: CaseIterable {
    case title
}

class EventDetailsViewController: UIViewController {
    let viewModel: EventDetailsViewModelProtocol
    
    var tableView: UITableView!
    
    init(viewModel: EventDetailsViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        tableView = UITableView()
        tableView.register(EventDetailsTableViewCell.self)
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

    override func viewDidLoad() {
        
    }
}

extension EventDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EventDetailsTableViewFields.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(EventDetailsTableViewCell.self, for: indexPath)
        
        cell.configure(with: viewModel.eventDetailsTableViewItem)
        
        return cell
    }
}
//
//enum EventCreationField: Int, CaseIterable {
//    case title
//    case date
//}
//
//class EventCreationViewController: UIViewController {
//    var viewModel: EventCreationViewModelProtocol!
//
//    var cancellables: Set<AnyCancellable> = Set()
//
//    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
//    @IBAction func doneBarButtonItemAction(_ sender: Any) {
//        viewModel.doneButtonPressed()
//        dismiss(animated: true)
//    }
//    
//    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
//    @IBAction func cancelBarButtonItemAction(_ sender: Any) {
//        viewModel.cancelButtonPressed()
//        dismiss(animated: true)
//    }
//
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil),
//                           forCellReuseIdentifier: TextFieldTableViewCell.identifier)
//        tableView.register(UINib(nibName: "DatePickerTableViewCell", bundle: nil),
//                           forCellReuseIdentifier: DatePickerTableViewCell.identifier)
//        tableView.dataSource = self
//    }
//}
//
//extension EventCreationViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return EventCreationField.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let eventCreationField = EventCreationField(rawValue: indexPath.row) else {
//            return UITableViewCell()
//        }
//
//        switch eventCreationField {
//        case .title:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: TextFieldTableViewCell.identifier,
//                for: indexPath
//            ) as! TextFieldTableViewCell
//
//            configureCellForTitleEventCreationField(cell)
//
//            return cell
//        case .date:
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: DatePickerTableViewCell.identifier,
//                for: indexPath
//            ) as! DatePickerTableViewCell
//
//            configureCellForDateEventCreationField(cell)
//
//            return cell
//        }
//    }
//
//    func configureCellForTitleEventCreationField(_ cell: TextFieldTableViewCell) {
//        let textField = cell.textField!
//        textField.placeholder = "Title"
//        textField.font = .systemFont(ofSize: 17)
//        textField.autocapitalizationType = .sentences
//        textField.text = viewModel.title
//
//        textField.publisher(for: .editingChanged)
//            .map { $0.text ?? "" }
//            .assign(to: &viewModel.titlePublisher)
//
//        textField.becomeFirstResponder()
//    }
//
//    func configureCellForDateEventCreationField(_ cell: DatePickerTableViewCell) {
//        let titleLabel = cell.titleLabel!
//        titleLabel.text = "Date"
//
//        let datePicker = cell.datePicker!
//        datePicker.date = viewModel.date
//
//        datePicker.publisher(for: .valueChanged)
//            .map { $0.date }
//            .assign(to: &viewModel.datePublisher)
//    }
//}
