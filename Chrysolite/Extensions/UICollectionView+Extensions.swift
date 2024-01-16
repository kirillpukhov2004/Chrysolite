import UIKit

extension UICollectionView {
    func register<T>(_ cellClass: T.Type) where T: UICollectionViewCell, T: IdentifiableView {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T>(_ type: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell, T: IdentifiableView  {
        guard let view = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError()
        }
        
        return view
    }
}
