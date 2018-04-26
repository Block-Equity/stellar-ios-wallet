import UIKit

extension UICollectionView {
    /// Cell
    func registerCell<T: UICollectionViewCell>(type: T.Type) where T: ReusableView, T: NibLoadableView {
        self.register(UINib(nibName: T.nibName, bundle: T.bundle), forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerCell<T: UICollectionViewCell>(type: T.Type) where T: ReusableView {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerHeader<T: UICollectionReusableView>(type: T.Type) where T: ReusableView, T: NibLoadableView {
        self.register(
            UINib(nibName: T.nibName, bundle: T.bundle),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func registerHeader<T: UICollectionReusableView>(type: T.Type) where T: ReusableView {
        self.register(
            T.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func registerFooter<T: UICollectionReusableView>(type: T.Type) where T: ReusableView, T: NibLoadableView {
        self.register(
            UINib(nibName: T.nibName, bundle: T.bundle),
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func registerFooter<T: UICollectionReusableView>(type: T.Type) where T: ReusableView {
        self.register(
            T.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return T()
        }
        return cell
    }

    func dequeueReusableHeader<T: UICollectionReusableView>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: T.reuseIdentifier,
                                                               for: indexPath) as? T else {
                                                                return T()
        }
        return view
    }

    func dequeueReusableFooter<T: UICollectionReusableView>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                               withReuseIdentifier: T.reuseIdentifier,
                                                               for: indexPath) as? T else {
                                                                return T()
        }
        return view
    }
}
