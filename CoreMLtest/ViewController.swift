//
//  ViewController.swift
//  CoreMLtest
//
//  Created by Kynan Song on 08/07/2018.
//  Copyright © 2018 Kynan Song. All rights reserved.
//  Learning from Brian Voong youtube video.

import UIKit
import AVKit
import Vision
//for image recognition

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var observationLabel: UILabel!
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //Need to create a label this way to display the text on the camera view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Shows the camera/ starts up the camera.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = .photo
        //Will crop the view frame.
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        //if device has no camera use try with a ? to avoid errors and guard statements to unwrap the optionals.
        //Need to set privacy settings in info.plist
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        //Output preview layer
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        //Add as sublayer to view controllers view.
        //Need to specify a frame for the preview layer/
        previewLayer.frame = view.frame
        //Activates the camera on view.
        
        //Access to camera frame layer.
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        //Needs a custom queue for the data. and self on the delegate as it is in the view controller.
        
        
        //Add to capture sessions.
        captureSession.addOutput(dataOutput)
        
        //Analyze camera data.
    
       // VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput  sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera captured a frame", Date())
        //Called everytime the camera captures a frame
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        //Needs to be unwrapped.
        
        guard let resNetModel = try? VNCoreMLModel(for: Resnet50().model) else {return }

        //Go to developer.apple.com/machine learning to find the right model
        //Using resNet50 Model, needs to be wrapped in VNCoreModel
        
        let request = VNCoreMLRequest(model: resNetModel) {
            (finishedRequest, error) in

            //cast results into an array.
            
            guard let resultsArray = finishedRequest.results as? [VNClassificationObservation] else {return}
            //VNCLassificationObservation is the object data.
            
            guard let firstObservation = resultsArray.first else {return}
            //What the camera thinks the object is.
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            //Label needs to be used on main thread.
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObservation.identifier)" + ": " + "\(firstObservation.confidence)"
            }
            
        }

        
        //Helps access VNImage request handler
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        //Execute request and tell us what the object is.
    }

    func addSubView() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

