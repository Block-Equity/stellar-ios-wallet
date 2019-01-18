//
//  QRMap.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-04.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

final class QRMap {
    enum CorrectionLevel: String, RawRepresentable {
        case lowest = "L"
        case minimal = "M"
        case high = "Q"
        case full = "H"
    }

    typealias PixelMap = (data: [Bool], width: Int, height: Int)

    private(set) var code: String
    private(set) var ciImage: CIImage?
    private(set) var map: PixelMap?
    private(set) var level: CorrectionLevel = .full

    func scaledTemplateImage(scale: CGFloat) -> UIImage? {
        guard let ciImage = self.scaledImage(scaleX: scale, scaleY: scale) else { return nil }

        let context = CIContext.init(options: nil)
        let image = UIImage(cgImage: context.createCGImage(ciImage, from: ciImage.extent)!)

        return image.withRenderingMode(.alwaysTemplate)
    }

    var cgImage: CGImage? {
        let context = CIContext(options: nil)

        guard let qrImage = self.ciImage, let image = context.createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }

        return image
    }

    init(with qrString: String, correctionLevel: CorrectionLevel) {
        code = qrString
        level = correctionLevel
        ciImage = generateQRImage()

        if let qrImage = cgImage {
            map = generatePixelMap(with: qrImage)
        }
    }

    func scaledImage(scaleX: CGFloat, scaleY: CGFloat) -> CIImage? {
        return self.ciImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

    private func generateQRImage() -> CIImage? {
        let data = code.data(using: .isoLatin1, allowLossyConversion: false)

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue(level.rawValue, forKey: "inputCorrectionLevel")

        guard let image = filter?.outputImage else { return nil }

        let invertFilter = CIFilter(name: "CIColorInvert")
        invertFilter?.setValue(image, forKey: kCIInputImageKey)

        let alphaFilter = CIFilter(name: "CIMaskToAlpha")
        alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)

        return alphaFilter?.outputImage
    }

    private func generatePixelMap(with imageRef: CGImage) -> PixelMap {
        let totalBytes = imageRef.height * imageRef.bytesPerRow
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(imageRef.width), height: CGFloat(imageRef.height))

        var pixelValues: [Bool]
        var intensities = [Bool](repeating: false, count: totalBytes)

        let contextRef = CGContext(data: &intensities,
                                   width: imageRef.width,
                                   height: imageRef.height,
                                   bitsPerComponent: imageRef.bitsPerComponent,
                                   bytesPerRow: imageRef.bytesPerRow,
                                   space: CGColorSpaceCreateDeviceGray(),
                                   bitmapInfo: 0)

        contextRef?.draw(imageRef, in: rect)
        pixelValues = intensities

        return (pixelValues, imageRef.width, imageRef.height)
    }
}
