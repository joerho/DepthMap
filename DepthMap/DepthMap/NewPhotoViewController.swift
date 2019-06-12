//
//  ViewController.swift
//  DepthMap
//
//  Created by joe rho on 5/3/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

import AVFoundation
import UIKit
import Photos
import ImageIO


class NewPhotoViewController: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var depthSlider: UISlider!

    
    var filterImage: CIImage?
    var originalImg: UIImage?
    var depthMapImg: UIImage?
    var cur = 0
    var bundle = [String]()
    var depthFilters: DepthImageFilters?
    let context = CIContext()
    var imageData: Data?
    var depthData: AVDepthData?
    var depthDataMap: CVPixelBuffer?
    var finalImage: UIImage?


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if depthData?.depthDataType != kCVPixelFormatType_DepthFloat32 {
            depthData = depthData?.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
            depthDataMap = depthData?.depthDataMap
        }
        depthFilters = DepthImageFilters(context: context)
        if(imageData == nil) {
            print ("lol")
        }
        
        loadCurrent(imageData: imageData!)
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateImageView()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateImageView()
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(finalImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}

extension NewPhotoViewController {
    
    func loadCurrent (imageData: Data) {
        depthDataMap?.normalize()
        let ciImage = CIImage(cvPixelBuffer: depthDataMap)
        depthMapImg = UIImage(ciImage: ciImage)
        originalImg = UIImage(data: imageData)
        filterImage = CIImage(image: originalImg)
        
        modeControl.selectedSegmentIndex = ImageMode.original.rawValue
        updateImageView()
    }
    
    func updateImageView() {
        
        depthSlider.isHidden = true
        imageView.image = nil
        
        let selectedImageMode = ImageMode(rawValue: modeControl.selectedSegmentIndex) ?? .original
        
        switch selectedImageMode {
        case .original:
            finalImage = originalImg
        case .depth:
            depthSlider.isHidden = false
            guard let depthImage = depthMapImg?.ciImage else {
                return
            }
            
            let maxToDim = max((originalImg?.size.width ?? 1.0), (originalImg?.size.height ?? 1.0))
            let maxFromDim = max((depthMapImg?.size.width ?? 1.0), (depthMapImg?.size.height ?? 1.0))
            let scale = maxToDim / maxFromDim
            guard let mask = depthFilters?.createMask(for: depthImage, withFocus: CGFloat(depthSlider.value), andScale: scale) else {
                return
            }
            
            let context = CIContext() // Prepare for create CGImage
            let cgimg = context.createCGImage(mask, from: mask.extent)
            let output = UIImage(cgImage:cgimg!, scale:originalImg!.scale, orientation:originalImg!.imageOrientation)
            finalImage = output
        case .color:
            depthSlider.isHidden = false
            
            guard let depthImage = depthMapImg?.ciImage else {
                return
            }
            
            let maxToDim = max((originalImg?.size.width ?? 1.0), (originalImg?.size.height ?? 1.0))
            let maxFromDim = max((depthMapImg?.size.width ?? 1.0), (depthMapImg?.size.height ?? 1.0))
            
            let scale = maxToDim / maxFromDim
            
            guard let mask = depthFilters?.createMask(for: depthImage, withFocus: CGFloat(depthSlider.value), andScale: scale),
                let filterImage = filterImage,
                let orientation = originalImg?.imageOrientation else {
                    return
            }
            
            finalImage = depthFilters?.colorHighlight(image: filterImage, mask: mask, orientation: orientation)

        case .blur:
            depthSlider.isHidden = false
            
            guard let depthImage = depthMapImg?.ciImage else {
                return
            }
            
            let maxToDim = max((originalImg?.size.width ?? 1.0), (originalImg?.size.height ?? 1.0))
            let maxFromDim = max((depthMapImg?.size.width ?? 1.0), (depthMapImg?.size.height ?? 1.0))
            
            let scale = maxToDim / maxFromDim
            
            guard let mask = depthFilters?.createMask(for: depthImage, withFocus: CGFloat(depthSlider.value), andScale: scale),
                let filterImage = filterImage,
                let orientation = originalImg?.imageOrientation else {
                    return
            }
            finalImage = depthFilters?.blur(image: filterImage, mask: mask, orientation: orientation)
        }
        imageView.image = finalImage
    }
}





