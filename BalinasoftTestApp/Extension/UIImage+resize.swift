//
//  UIImage+resize.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 23.09.23.
//

import Foundation
import UIKit

extension UIImage {
    
    func resizeToDataSize(_ dataSize: Int) -> UIImage? {
        if let imageData = self.pngData(), imageData.count > dataSize {
            let percent = CGFloat(imageData.count) / CGFloat(dataSize)
            let newWidth = self.size.width / (percent * 1.1)
            let scale = newWidth / self.size.width
            let newHeight = self.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else {
            return self
        }
    }
}
