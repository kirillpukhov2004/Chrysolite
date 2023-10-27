import UIKit

struct CalendarCollectionViewItem {
    let date: String
    let font: UIFont
}

class CalendarCollectionViewCell: UICollectionViewCell, IdentifiableView {
    static let identifier = "CalendarCollectionViewCell"
    
    private var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CalendarCollectionViewItem) {
        label.text = item.date
        label.font = item.font
    }
}

class CalendarView: UIView {
    var monthLabel: UILabel!
    
    var yearLabel: UILabel!
    
    var collectionView: UICollectionView!
    
    var selectedDateIndicatorView: UIView!
    
    var selectedDate: Date! {
        didSet {
            if !Calendar.current.isDate(selectedDate, equalTo: oldValue, toGranularity: .month) {
                updateLabels()
                updateDates()
            }
            
            updateSelectedDateIndicator()
        }
    }
    
    private var dates: [Date]!
    
    init(selectedDate: Date) {
        super.init(frame: .zero)
        
        self.selectedDate = selectedDate
        
        monthLabel = UILabel()
        monthLabel.font = UIFont.systemFont(ofSize: 27, weight: .medium, design: .rounded)
        addSubview(monthLabel)
        
        yearLabel = UILabel()
        yearLabel.font = UIFont.systemFont(ofSize: 27, design: .rounded)
        addSubview(yearLabel)
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        selectedDateIndicatorView = UIView()
        selectedDateIndicatorView.backgroundColor = .white.withAlphaComponent(0.35)
        selectedDateIndicatorView.layer.cornerRadius = 10
        addSubview(selectedDateIndicatorView)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            monthLabel.topAnchor.constraint(equalTo: topAnchor),
            
        ])
        
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 8),
            yearLabel.topAnchor.constraint(equalTo: monthLabel.topAnchor),
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
        
        selectedDateIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        updateLabels()
        updateDates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateDates() {
        var dates = [Date]()

        // monthDateInterval is between first day of given month and first day of the following month
        let monthDateInterval = Calendar.current.dateInterval(of: .month, for: selectedDate)!
        let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthDateInterval.start)!

        dates.append(monthFirstWeek.start)
        Calendar.current.enumerateDates(startingAfter: monthFirstWeek.start, matching: .init(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }

            if dates.count < 42 {
                dates.append(date)
            } else {
                stop = true
            }
        }

        self.dates = dates
        collectionView.reloadData()
    }
    
    private func updateLabels() {
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MMMM"
        
        monthLabel.text = monthDateFormatter.string(from: selectedDate)
        
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "YYYY"
        
        yearLabel.text = yearDateFormatter.string(from: selectedDate)
    }
    
    private func updateSelectedDateIndicator() {
        guard let row = dates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) else { return }

        guard let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) else { return }
        
        NSLayoutConstraint.deactivate(constraints.filter({ $0.firstItem === selectedDateIndicatorView }))
        
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        
        if cell.frame.height > cell.frame.width {
            widthConstraint = selectedDateIndicatorView.widthAnchor.constraint(equalTo: cell.widthAnchor)
            heightConstraint = selectedDateIndicatorView.heightAnchor.constraint(equalTo: cell.widthAnchor)
        } else {
            widthConstraint = selectedDateIndicatorView.widthAnchor.constraint(equalTo: cell.heightAnchor)
            heightConstraint = selectedDateIndicatorView.heightAnchor.constraint(equalTo: cell.heightAnchor)
        }
        
        NSLayoutConstraint.activate([
            selectedDateIndicatorView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            selectedDateIndicatorView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            widthConstraint,
            heightConstraint
        ])
        
        UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell {
        let date = dates[indexPath.row]
        let item = CalendarCollectionViewItem(
            date: "\(Calendar.current.component(.day, from: date))",
            font: .systemFont(ofSize: 15, weight: (Calendar.current.isDateInToday(date) ? .black : .regular), design: .rounded)
        )
        
        let cell = collectionView.dequeueReusableCell(CalendarCollectionViewCell.self, for: indexPath)
        cell.configure(with: item)
        
        return cell
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.bounds.width / 7, height: collectionView.bounds.height / 6)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
}
