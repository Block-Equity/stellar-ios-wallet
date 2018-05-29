//
//  PinDotViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

struct PinDotViewModel {
    var circleDiameter: CGFloat = CGFloat(15)
    var lineHeight: CGFloat = CGFloat(2)
    var lineColor: UIColor = .white
    var dotColor: UIColor = .white
    var shakeColor: UIColor = .red
    var shakeOffset: CGFloat = CGFloat(30)
}

class PinDotView : UIView {
    let speed = 0.75

    private enum PinState {
        case dot
        case transitioning
        case shaking
        case line
    }

    typealias ViewState = (bounds: CGRect, frame: CGRect, radius: CGFloat, color: UIColor)

    private var state: PinState = .line
    private var pinView: UIView!
    private var lineState: ViewState?
    private var viewModel: PinDotViewModel = PinDotViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func update(with viewModel: PinDotViewModel) {
        self.viewModel = viewModel

        if state == .line {
            self.pinView.backgroundColor = viewModel.lineColor
        } else {
            self.pinView.backgroundColor = viewModel.dotColor
        }
    }

    func setupView() {
        pinView = UIView()
        pinView.backgroundColor = viewModel.lineColor
        pinView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pinView)

        NSLayoutConstraint.activate([
            pinView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            pinView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            pinView.widthAnchor.constraint(equalToConstant: viewModel.circleDiameter),
            pinView.heightAnchor.constraint(equalToConstant: viewModel.lineHeight),
            ])
    }

    func animateToCircle() {
        guard state == .line else { return }

        // Record the state of the view before beginning the animation
        lineState = (bounds: self.pinView.bounds,
                     frame: self.pinView.frame,
                     radius: self.pinView.layer.cornerRadius,
                     color: self.pinView.backgroundColor!)

        // Line to dot
        let animator1 = UIViewPropertyAnimator(duration: speed * 0.1, curve: .easeIn) {
            self.pinView.bounds.size.height = self.viewModel.lineHeight
            self.pinView.bounds.size.width = self.viewModel.lineHeight
            self.pinView.frame.origin.y = self.pinView.frame.origin.y - 5
        }

        // Dot to circle
        let animator2 = UIViewPropertyAnimator(duration: speed * 0.4, dampingRatio: 0.55) {
            self.pinView.bounds.size.width = self.viewModel.circleDiameter
            self.pinView.bounds.size.height = self.viewModel.circleDiameter
            self.pinView.frame.origin.y = self.pinView.frame.origin.y - self.viewModel.circleDiameter
            self.pinView.layer.cornerRadius = self.pinView.frame.width / 2
        }

        // Background color
        let animator3 = UIViewPropertyAnimator(duration: speed * 0.25, curve: .easeInOut) {
            self.pinView.backgroundColor = self.viewModel.dotColor
        }

        animator1.addCompletion { _ in
            animator2.startAnimation()
            animator3.startAnimation()
        }

        animator2.addCompletion { _ in
            self.state = .dot
        }

        animator1.startAnimation()
        state = .transitioning
    }

    func animateToLine() {
        guard state == .dot else { return }

        // Background color
        let animator1 = UIViewPropertyAnimator(duration: speed * 0.5, dampingRatio: 0.7) {
            self.pinView.backgroundColor = self.lineState!.color
        }

        // Circle to dot
        let animator2 = UIViewPropertyAnimator(duration: speed * 0.1, curve: .easeIn) {
            self.pinView.bounds.size.width = self.viewModel.lineHeight
            self.pinView.bounds.size.height = self.viewModel.lineHeight
            self.pinView.frame.origin.y = self.lineState!.frame.origin.y - 5
            self.pinView.layer.cornerRadius = 0
        }

        // Dot to line
        let animator3 = UIViewPropertyAnimator(duration: speed * 0.1, curve: .easeOut) {
            self.pinView.bounds = self.lineState!.bounds
            self.pinView.frame = self.lineState!.frame
        }

        animator2.addCompletion { _ in
            animator3.startAnimation()
        }

        animator3.addCompletion { _ in
            self.state = .line
        }

        animator1.startAnimation()
        animator2.startAnimation()

        state = .transitioning
    }

    func shake(completion: (() -> Void)?) {
        guard state == .dot else { return }

        let centeredX = self.pinView.frame.origin.x
        let leftX = centeredX - viewModel.shakeOffset
        let rightX = centeredX + viewModel.shakeOffset

        let time = 1.0 * speed - 0.15
        let timeFactor = CGFloat(time / 4)
        let animationDelays = [timeFactor, timeFactor * 2, timeFactor * 3]

        self.state = .shaking

        // left, right, left, center
        let shakeAnimator = UIViewPropertyAnimator(duration: time, curve: .linear) {
            self.pinView.frame.origin.x = leftX
        }
        shakeAnimator.addAnimations({ self.pinView.frame.origin.x = rightX }, delayFactor: animationDelays[0])
        shakeAnimator.addAnimations({ self.pinView.frame.origin.x = leftX }, delayFactor: animationDelays[1])
        shakeAnimator.addAnimations({ self.pinView.frame.origin.x = centeredX }, delayFactor: animationDelays[2])
        shakeAnimator.startAnimation()

        let colorAnimator = UIViewPropertyAnimator(duration: time / 3, curve: .easeOut) {
            self.pinView.backgroundColor = self.viewModel.shakeColor
        }
        colorAnimator.startAnimation()

        shakeAnimator.addCompletion { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.state = .dot
                completion?()
            })
        }
    }

    func reset() {
        guard let viewState = lineState else { return }

        state = .line
        pinView.frame = viewState.frame
        pinView.bounds = viewState.bounds
        pinView.backgroundColor = viewState.color
        pinView.layer.cornerRadius = viewState.radius
    }
}
