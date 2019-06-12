//
//  CIImageExtension.swift
//  DepthMap
//
//  Created by joe rho on 5/4/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

import UIKit

extension CIImage {
    
    convenience init?(image: UIImage?) {
        
        guard let image = image else {
            return nil
        }
        
        self.init(image: image)
    }
    
    convenience init?(cvPixelBuffer: CVPixelBuffer?) {
        
        guard let cvPixelBuffer = cvPixelBuffer else {
            return nil
        }
        
        self.init(cvPixelBuffer: cvPixelBuffer)
    }
    
    convenience init?(cgImage: CGImage?) {
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
}
