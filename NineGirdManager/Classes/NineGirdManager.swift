
//
//  NineGirdManager.swift
//
//
//  Created by apple on 4/19/21.
//

public class NineGirdManager: NSObject {
    public static let shared = NineGirdManager()
    
    public func cropGirdPicturesWithColumnCount(image: UIImage, borderWidth: Int = 0 ,columnCount: Int, rowCount: Int, bgColor: UIColor = UIColor.clear, errorBlock: () -> Void, completeBlock: (UIImage?, [UIImage]?, Int, Int) -> Void) {
        guard let image = fixOrientation(image) else {
            errorBlock()
            return
        }
        
        guard let imageRef = image.cgImage else {
            errorBlock()
            return
        }
        
        let imageWidth: CGFloat = CGFloat(imageRef.width)
        let imageHeight: CGFloat = CGFloat(imageRef.height)
        let borderWidth: CGFloat = imageWidth*5/268
        let renderWidth: CGFloat = CGFloat(imageWidth - CGFloat(borderWidth*CGFloat((columnCount-1)))) / CGFloat(columnCount)
        let renderHeight: CGFloat = CGFloat(imageHeight - CGFloat(borderWidth*CGFloat((rowCount-1)))) / CGFloat(rowCount)
        let renderSize = CGSize(width: renderWidth, height: renderHeight)
        var fragmentsResults: [UIImage]? = []
        
        for i in 0..<rowCount {
            for j in 0..<columnCount {
                autoreleasepool {
                    var x: CGFloat = -renderWidth * CGFloat(j)
                    if j > 0 {
                        print("xxx=x", x, j, borderWidth)
                        x = x - CGFloat(borderWidth * CGFloat(j))
                    }
                    print("xxx=x", x, (j))
                    
                    
                    var y: CGFloat = -renderHeight * CGFloat(i)
                    if i > 0 {
                        print("xxx=y", y, i, borderWidth)
                        y = y - CGFloat(borderWidth * CGFloat(i))
                    }
                    print("xxx=y", y, i)
                    
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: renderSize.width, height: renderSize.height))
                    let singleImage = renderer.image { context in
                        image.draw(at: CGPoint(x: x, y: y))
                    }
                    
                    fragmentsResults?.append(singleImage)
                }
            }
        }
        
        completeBlock(image, fragmentsResults, columnCount, rowCount)
    }

    func fixOrientation(_ image: UIImage?) -> UIImage? {
        guard let image = image else {
            return nil
        }
          if (image.imageOrientation == .up) {
          return image
        }
        
          var transform = CGAffineTransform.identity
        
        switch (image.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
          
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
          
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi/2)
          
        default:
          break
        }
        
        switch (image.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
          
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
          
        default:
          break
        }
        
        guard let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height),
                                    bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                    space: image.cgImage!.colorSpace!,
                                    bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
              return UIImage()
        }
        
        ctx.concatenate(transform)
        guard let cgImage = image.cgImage else {
            return nil
        }
        switch (image.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let cgimg = ctx.makeImage() else {
            return nil
        }
        return UIImage(cgImage: cgimg)
    }

}

