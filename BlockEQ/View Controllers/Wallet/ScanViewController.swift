//
//  ScanViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import AVFoundation
import UIKit

protocol ScanViewControllerDelegate: AnyObject {
    func dismiss(_ viewController: ScanViewController)
    func setQR(_ viewController: ScanViewController, value: String)
}

class ScanViewController: UIViewController {
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]

    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    var hasIdentifiedQR: Bool = false
    weak var delegate: ScanViewControllerDelegate?

    deinit {
        captureSession.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCamera()
    }

    func setupView() {
        navigationItem.title = "SCANNING".localized()
    }

    func addDismissButton() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @objc func dismissView() {
        delegate?.dismiss(self)
    }

    func presentInvalidQRCode() {
        UIAlertController.callbackAlert(title: "UNRECOGNIZED_ADDRESS_ERROR_TITLE".localized(),
                                        message: "UNRECOGNIZED_ADDRESS_ERROR_MESSAGE".localized(),
                                        presentingViewController: self, handler: { _ in
                                            self.navigationItem.title = "SCANNING".localized()
                                            self.hasIdentifiedQR = false
        })
    }

    func setupCamera() {
        let captureDevices: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInWideAngleCamera]
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: captureDevices,
                                                                      mediaType: AVMediaType.video,
                                                                      position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("No Camera Found.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        view.layer.addSublayer(videoPreviewLayer!)

        captureSession.startRunning()

        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = Colors.primaryDark.cgColor
            qrCodeFrameView.layer.borderWidth = 3.0
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
            return
        }

        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            guard let qrValue = metadataObj.stringValue, !hasIdentifiedQR else { return }

            hasIdentifiedQR = true
            navigationItem.title = "QR_DETECTED".localized()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.setQR(self, value: qrValue)
            }
        }
    }
}
