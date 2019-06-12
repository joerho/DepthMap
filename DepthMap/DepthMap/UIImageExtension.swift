//
//  UIImageExtension.swift
//  DepthMap
//
//  Created by joe rho on 5/4/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(ciImage: CIImage?) {
        
        guard let ciImage = ciImage else {
            return nil
        }
        
        self.init(ciImage: ciImage)
    }
}

