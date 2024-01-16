import UIKit

extension UITableView {
    func register<T>(_ cellClass: T.Type) where T: UITableViewCell, T: IdentifiableView {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
    
    func dequeueReusableCell<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell, T: IdentifiableView {
        guard let view = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError()
        }
        
        return view
    }
    
    func register<T>(_ headerClass: T.Type) where T: UITableViewHeaderFooterView, T: IdentifiableView {
        register(headerClass, forHeaderFooterViewReuseIdentifier: headerClass.identifier)
    }
    
    func dequeueReusableHeaderFooterView<T>(_ cellClass: T.Type) -> T where T: UITableViewHeaderFooterView, T: IdentifiableView {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError()
        }
        
        return view
    }
}

// https://stackoverflow.com/questions/15204328/how-to-retrieve-all-visible-table-section-header-views
extension UITableView {
    var indexesOfVisibleSections: [Int] {
            // Note: We can't just use indexPathsForVisibleRows, since it won't return index paths for empty sections.
            var visibleSectionIndexes = [Int]()

            for sectionIndex in 0..<numberOfSections {
                var headerRect: CGRect
                // In plain style, the section headers are floating on the top, so the section header is visible if any part of the section's rect is still visible.
                // In grouped style, the section headers are not floating, so the section header is only visible if it's actualy rect is visible.
                if (style == .plain) {
                    headerRect = rect(forSection: sectionIndex)
                } else {
                    headerRect = rectForHeader(inSection: sectionIndex)
                }
                
                if #available(iOS 15.0, *) {
                    headerRect = CGRect(
                        x: headerRect.origin.x,
                        y: headerRect.origin.y - sectionHeaderTopPadding,
                        width: headerRect.width,
                        height: headerRect.height + sectionHeaderTopPadding
                    )
                }
                
                // The "visible part" of the tableView is based on the content offset and the tableView's size.
                let visiblePartOfTableView = CGRect(origin: contentOffset, size: bounds.size)
                if visiblePartOfTableView.intersects(headerRect) {
                    visibleSectionIndexes.append(sectionIndex)
                }
            }
        
            return visibleSectionIndexes
        }

        var visibleSectionHeaders: [UITableViewHeaderFooterView] {
            var visibleSects = [UITableViewHeaderFooterView]()
            for sectionIndex in indexesOfVisibleSections {
                if let sectionHeader = headerView(forSection: sectionIndex) {
                    visibleSects.append(sectionHeader)
                }
            }

            return visibleSects
        }
}

