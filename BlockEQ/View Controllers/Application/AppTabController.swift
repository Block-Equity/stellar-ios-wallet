//
//  AppTabController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

enum ApplicationTab: Int {
    case assets
    case trading
    case settings

    var tabBarItem: UITabBarItem {
        return UITabBarItem(title: title,
                            image: inactiveImage,
                            selectedImage: activeImage)
    }

    var title: String {
        switch self {
        case .assets: return "TITLE_TAB_ASSETS".localized()
        case .trading: return "TITLE_TAB_TRADING".localized()
        case .settings: return "TITLE_TAB_SETTINGS".localized()
        }
    }

    var activeImage: UIImage {
        var image: UIImage?
        switch self {
        case .assets: image = UIImage(named: "wallet")
        case .trading: image = UIImage(named: "trading")
        case .settings: image = UIImage(named: "settings")
        }

        return image!
    }

    var inactiveImage: UIImage {
        var image: UIImage?
        switch self {
        case .assets: image = UIImage(named: "wallet")
        case .trading: image = UIImage(named: "trading")
        case .settings: image = UIImage(named: "settings")
        }

        return image!
    }

    static func matchingTabType(for tabItem: UITabBarItem) -> ApplicationTab? {
        for type in ApplicationTab.all where type.title == tabItem.title {
            return type
        }

        return nil
    }

    static var all: [ApplicationTab] {
        // TODO: Trading removed from first release to be added for subsequent release.
        return [.assets, .settings]
    }

    var tabNumber: Int {
        return self.rawValue
    }
}

protocol AppTabControllerDelegate: AnyObject {
    func switchedTabs(_ type: ApplicationTab)
}

final class AppTabController: ContainerViewController {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var tabBar: UITabBar!

    static let defaultTab: ApplicationTab = .assets

    private var tabItems: [UITabBarItem] = []
    private var currentTab: ApplicationTab = AppTabController.defaultTab
    weak var tabDelegate: AppTabControllerDelegate?

    convenience init(tab: ApplicationTab) {
        self.init(nibName: nil, bundle: nil)
        currentTab = tab
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTabs()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTabs()
    }

    private func setupTabs() {
        tabItems = ApplicationTab.all.map { $0.tabBarItem }
    }

    func reset() {
        currentTab = AppTabController.defaultTab
    }

    func update() {
        select(currentTab)
    }

    private func select(_ tab: ApplicationTab) {
        if let item = tabItems.filter({ $0.title == tab.title }).first {
            tabBar.selectedItem = item
        }
    }

    func moveTo(tab: ApplicationTab) {
        if let item = tabItems.filter({ $0.title == tab.title }).first {
            tabBar.selectedItem = item
            updateCurrentTab(with: tabBar.selectedItem!)
        }
    }

    private func updateCurrentTab(with item: UITabBarItem) {
        if let type = ApplicationTab.matchingTabType(for: item) {
            select(type)
            tabDelegate?.switchedTabs(type)
            currentTab = type
            currentViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        tabBar.delegate = self
        tabBar.tintColor = Colors.primaryDark
        tabBar.setItems(tabItems, animated: false)
        tabBar.selectedItem = tabItems.first
    }

    override func setViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let current = currentViewController {
            current.willMove(toParentViewController: nil)
            current.view.removeFromSuperview()
            current.removeFromParentViewController()
        }

        addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        viewController.view.frame = container.bounds
        currentViewController = viewController

        completion?()
    }
}

extension AppTabController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        updateCurrentTab(with: item)
    }
}
