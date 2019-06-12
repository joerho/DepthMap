//
//  CustomCameraViewController.swift
//  DepthMap
//
//  Created by joe rho on 6/2/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

// format
// url vs data
//
import UIKit
import AVFoundation


class CustomCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var imageData: Data?
    var depthData: AVDepthData?
    var depthDataMap: CVPixelBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        warning()
        prepareCamera()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        //beginSession()

    }
    
    func warning() {
        let alert = UIAlertController(title: "Warning",
                                      message: "In order to get depth information, the device must have a built in dual camera.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        print(availableDevices)
        captureDevice = availableDevices.first
    }
    // format: [AVVideoCodecKey: AVVideoCodecType.hevc])
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            //let pixelFormatType = "kCVPixelFormatType_DisparityFloat32"
//            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg]
//                )], completionHandler: nil)
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.hevc])], completionHandler: nil)

            //captureSession.addOutput(photoOutput!)
            if captureSession.canAddOutput(photoOutput!) {
                captureSession.addOutput(photoOutput!)

                photoOutput!.isDepthDataDeliveryEnabled = photoOutput!.isDepthDataDeliverySupported


            }
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(previewLayer, at: 0)
        
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @IBAction func captureButtonPressed(_ sender: Any) {
        //let setting = AVCapturePhotoSettings()
        // Use the current device's first available RAW format.
        
        
        //let pixelFormatType = kCVPixelFormatType_32RGBA
        //guard self.photoOutput!.availablePhotoPixelFormatTypes.contains(pixelFormatType) else { print("shit"); return }
//        guard let availableFormatType = self.photoOutput?.availablePhotoPixelFormatTypes.first else {        print("capturenah"); return }
//        let photoSettings = AVCapturePhotoSettings(format:
//            [ kCVPixelBufferPixelFormatTypeKey as String : availableFormatType ])
//
//        guard let availableRawFormat = self.photoOutput?.availableRawPhotoPixelFormatTypes.first else {        print("capturenah"); return }
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = photoOutput!.isDepthDataDeliveryEnabled

         //RAW capture is incompatible with digital image stabilization.
//        photoSettings.isAutoStillImageStabilizationEnabled = false

         //Shoot the photo, using a custom class to handle capture delegate callbacks.
        //let captureProcessor = RAWCaptureProcessor()
        photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        //performSegue(withIdentifier: "showImage", sender: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            //self.photoOutput!.isDepthDataDeliveryEnabled = photoOutput!.isDepthDataDeliverySupported
            let previewVC = segue.destination as! NewPhotoViewController
            previewVC.imageData = self.imageData
            previewVC.depthDataMap = self.depthDataMap
            previewVC.depthData = self.depthData
            
        }
    }
}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let imageData = photo.fileDataRepresentation() {
            self.imageData = imageData
            self.depthDataMap = photo.depthData?.depthDataMap
            self.depthData = photo.depthData
            performSegue(withIdentifier: "showImage", sender: nil)
        }
        
    }
}
