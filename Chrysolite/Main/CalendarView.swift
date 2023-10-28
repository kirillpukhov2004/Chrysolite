import UIKit

struct CalendarCollectionViewCellModel {
    let labelText: String
    let isLabelEnabled: Bool
}

class CalendarCollectionViewCell: UICollectionViewCell, IdentifiableView {
    static let identifier = "CalendarCollectionViewCell"
    
    private var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: bounds)
        label.font = .systemFont(ofSize: 15, weight: .regular, design: .rounded)
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: CalendarCollectionViewCellModel) {
        label.text = model.labelText
        label.isEnabled = model.isLabelEnabled
    }
}

class CalendarView: UIView {
    var collectionView: UICollectionView!
    
    var backgroundView: UIView!
    
    var indicatorView: UIView!
    
    var selectedDate = Date() {
        didSet {
            if !Calendar.current.isDate(selectedDate, equalTo: oldValue, toGranularity: .month) {
                dates = getDates()
                collectionView.reloadData()
            }
            
            updateIndicator()
        }
    }
    
    private var dates = [Date]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        
        backgroundView = UIView()
        backgroundView.backgroundColor = .secondarySystemBackground
        backgroundView.layer.cornerRadius = 13
        insertSubview(backgroundView, belowSubview: collectionView)
        
        indicatorView = UIView()
        indicatorView.backgroundColor = .white.withAlphaComponent(0.35)
        addSubview(indicatorView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 0.75)
        ])
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        dates = getDates()
        
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewCellMinDimension: CGFloat = min(collectionView.bounds.width / 7, collectionView.bounds.height / 6)
        let backgroundViewWidth: CGFloat = collectionView.bounds.width - (collectionView.bounds.width - (collectionViewCellMinDimension * 7 + ((collectionView.bounds.width / 7 - collectionViewCellMinDimension) * 6)))
        let backgroundViewHeight: CGFloat = collectionView.bounds.height
        let backgroundViewXOrigin: CGFloat = collectionView.frame.minX + (collectionView.bounds.width - backgroundViewWidth) / 2
        let backgroundViewYOrigin: CGFloat = collectionView.frame.minY
        
        backgroundView.frame = CGRect(x: backgroundViewXOrigin, y: backgroundViewYOrigin, width: backgroundViewWidth, height: backgroundViewHeight).inset(by: UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1))
    }
    
    private func getDates() -> [Date] {
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

        return dates
    }
    
    private func updateIndicator() {
        guard let row = dates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) else { return }

        guard let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) else { return }
        
        NSLayoutConstraint.deactivate(constraints.filter({ $0.firstItem === indicatorView }))
        
        if cell.frame.height > cell.frame.width {
            indicatorView.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
            indicatorView.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        } else {
            indicatorView.widthAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
            indicatorView.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            
            layoutIfNeeded()
            
            var topLeftRadius: CGFloat = 3
            var topRightRadius: CGFloat = 3
            var bottomLeftRadius: CGFloat = 3
            var bottomRightRadius: CGFloat = 3
            
            let dateIndex = dates.firstIndex(of: selectedDate)!
            if dateIndex == 0 {
                topLeftRadius = 13
            } else if dateIndex == 6 {
                topRightRadius = 13
            } else if dateIndex == 35 {
                bottomLeftRadius = 13
            } else if dateIndex == 41 {
                bottomRightRadius = 13
            }
            
            let rect = indicatorView.bounds.inset(by: UIEdgeInsets(top: 1.5, left: 1.5, bottom: 1.5, right: 1.5))
            
            let minx = CGRectGetMinX(rect)
            let miny = CGRectGetMinY(rect)
            let maxx = CGRectGetMaxX(rect)
            let maxy = CGRectGetMaxY(rect)

            let path = UIBezierPath()
            path.move(to: CGPointMake(minx + topLeftRadius, miny))
            path.addLine(to: CGPointMake(maxx - topRightRadius, miny))
            path.addArc(withCenter: CGPointMake(maxx - topRightRadius, miny + topRightRadius), radius: topRightRadius, startAngle: 3 * .pi / 2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPointMake(maxx, maxy - bottomRightRadius))
            path.addArc(withCenter: CGPointMake(maxx - bottomRightRadius, maxy - bottomRightRadius), radius: bottomRightRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPointMake(minx + bottomLeftRadius, maxy))
            path.addArc(withCenter: CGPointMake(minx + bottomLeftRadius, maxy - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPointMake(minx, miny + topLeftRadius))
            path.addArc(withCenter: CGPointMake(minx + topLeftRadius, miny + topLeftRadius), radius: topLeftRadius, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: true)
            path.close()
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            indicatorView.layer.mask = maskLayer
        }
    }
}

extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath ) -> UICollectionViewCell {
        let date = dates[indexPath.row]
        let model = CalendarCollectionViewCellModel(
            labelText: "\(Calendar.current.component(.day, from: date))",
            isLabelEnabled: Calendar.current.isDate(selectedDate, equalTo: date, toGranularity: .month)
        )
        
        let cell = collectionView.dequeueReusableCell(CalendarCollectionViewCell.self, for: indexPath)
        cell.configure(with: model)
        
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
