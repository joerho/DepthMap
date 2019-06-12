//
//  DepthReader.swift
//  DepthMap
//
//  Created by joe rho on 5/4/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

import AVFoundation
import UIKit

struct DepthReader {
    var name: String
    var ext: String
    
    func depthDataMap() -> CVPixelBuffer? {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: ext) as CFURL?
            else {
                return nil
        }
        
        guard let source = CGImageSourceCreateWithURL(fileURL, nil) else {
            return nil
        }
        
        print(CGImageSourceCopyProperties(source, nil))

        
        
        guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
            return nil
        }
        

        var depthData: AVDepthData
        
        do {
            depthData = try AVDepthData(fromDictionaryRepresentation: auxDataInfo)
        } catch {
            return nil
        }
        
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            print (depthData.depthDataType)
            depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
            print (depthData.depthDataType)
        }
        
        return depthData.depthDataMap
    }
}

struct DepthReaderImage {
    var imageData: Data
    
    func depthDataMap() -> CVPixelBuffer? {

 
        //let imgData = img.jpegData(compressionQuality: 1.0)!
        //let imgData = img.pData()!

//        imgData.withUnsafeBytes {(uint8Ptr: UnsafePointer<UInt8>)  in
//            let rawPtr = UnsafeRawPointer(uint8Ptr)
//        }
//        var imgCFData = CFDataCreate(kCFAllocatorDefault, rawPtr, imgData.length())
        
        //let uint8Ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: imgData.count)
        //uint8Ptr.initialize(from: imgData) //<-copying the data
        //You need to keep `uint8Ptr` and `data.count` for future management
        //let uint8PtrCount = imgData.count
        //You can convert it to `UnsafeRawPointer`
        //let rawPtr = UnsafeRawPointer(uint8Ptr)
        
        //let imgCFData = CFDataCreate(kCFAllocatorDefault, uint8Ptr, uint8PtrCount)!
        

        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            print ("hi0")
            return nil
        }
        
        guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
            print ("ERROR: No Auxiliary Data Found. (kCGImageAuxiliaryDataTypeDisparity) check to see if dual camera.")
            return nil
        }
        
        
        var depthData: AVDepthData
        
        do {
            depthData = try AVDepthData(fromDictionaryRepresentation: auxDataInfo)
        } catch {
            print ("hi2")

            return nil
        }
        
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        }
        
        return depthData.depthDataMap
    }
}

