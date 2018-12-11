//
//  ContainerViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

typealias ViewControllerContainer = (ContainerViewController & ContainerProtocol)

protocol ContainerProtocol: AnyObject {
    func setViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}

// This is an extendable class that passes through the preferred status bar colour of the last child. Since we're
// using this class as a container for other view controllers, this will allow the proper status bar colour setting.
class WrapperVC: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return children.last?.preferredStatusBarStyle ?? .default
    }
}

// Simple class that contains a child view controller while keeping track of the current view controller. This class
// Should never become large and have any other responsibility than managing how the provided view controller appears
// in the view hierarchy.
class ContainerViewController: UIViewController, ContainerProtocol {
    var currentViewController: UIViewController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        currentViewController = nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (currentViewController?.preferredStatusBarStyle) ?? .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        currentViewController = nil
    }

    func setViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        moveToViewController(viewController,
                             fromViewController: currentViewController,
                             animated: animated) {
                                self.currentViewController = viewController
                                viewController.setNeedsStatusBarAppearanceUpdate()
                                completion?()
        }
    }
}

extension UIViewController {
    func addContentViewController(_ viewController: UIViewController, to view: UIView) {
        addChild(viewController)
        addContentView(viewController.view, to: view)
        viewController.didMove(toParent: self)
    }

    func addContentView(_ view: UIView, to holderView: UIView) {
        adjustFrameForView(view)
        holderView.addSubview(view)
    }

    func addContentViewController(_ viewController: UIViewController) {
        addChild(viewController)
        addContentView(viewController.view)
        viewController.didMove(toParent: self)
    }

    func addContentView(_ contentView: UIView) {
        adjustFrameForView(contentView)
        view.addSubview(contentView)
    }

    func adjustFrameForView(_ view: UIView) {
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.frame = self.view.bounds
    }

    func moveToViewController(
        _ toViewController: UIViewController,
        fromViewController: UIViewController?,
        animated: Bool,
        completion:(() -> Void)?
        ) {
        if toViewController == fromViewController {
            completion?()
            return
        }

        if fromViewController == nil {
            addContentViewController(toViewController)
            completion?()
        } else {
            addChild(toViewController)
            adjustFrameForView(toViewController.view)
            fromViewController!.willMove(toParent: nil)
            transition(
                from: fromViewController!,
                to: toViewController,
                duration: animated ? 0.2 : 0.0,
                options: UIView.AnimationOptions.transitionCrossDissolve,
                animations: nil,
                completion: { _ in
                    fromViewController!.removeFromParent()
                    toViewController.didMove(toParent: self)
                    completion?()
            }
            )
        }
    }
}
