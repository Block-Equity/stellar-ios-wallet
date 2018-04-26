import UIKit

extension UITableView {
    /// Cell
    func registerCell<T: UITableViewCell>(type: T.Type) where T: ReusableView, T: NibLoadableView {
        self.register(UINib(nibName: T.nibName, bundle: T.bundle), forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerCell<T: UITableViewCell>(type: T.Type) where T: ReusableView {
        self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return T(style: .default, reuseIdentifier: T.reuseIdentifier)
        }
        return cell
    }

    /// Header View
    func registerHeader<T: UITableViewHeaderFooterView>(type: T.Type) where T: ReusableView, T: NibLoadableView {
        self.register(UINib(nibName: T.nibName, bundle: T.bundle), forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func registerHeader<T: UITableViewHeaderFooterView>(type: T.Type) where T: ReusableView {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableHeader<T: UITableViewHeaderFooterView>(reuseIdentifier: String? = nil) -> T where T: ReusableView {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier ?? T.reuseIdentifier) as? T else {
            return T(reuseIdentifier: reuseIdentifier ?? T.reuseIdentifier)
        }
        return view
    }

    /// Footer View
    func registerFooter<T: UITableViewHeaderFooterView>(type: T.Type, reuseIdentifier: String? = nil) where T: ReusableView, T: NibLoadableView {
        self.register(UINib(nibName: T.nibName, bundle: T.bundle), forHeaderFooterViewReuseIdentifier: reuseIdentifier ?? T.reuseIdentifier)
    }

    func dequeueReusableFooter<T: UITableViewHeaderFooterView>(reuseIdentifier: String? = nil) -> T where T: ReusableView {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier ?? T.reuseIdentifier) as? T else {
            return T(reuseIdentifier: reuseIdentifier ?? T.reuseIdentifier)
        }
        return view
    }
}
