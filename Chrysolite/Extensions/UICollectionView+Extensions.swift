import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell & IdentifiableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError()
        }
        
        return view
    }
}
