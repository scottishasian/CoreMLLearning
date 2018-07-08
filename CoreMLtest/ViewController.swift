//
//  ViewController.swift
//  CoreMLtest
//
//  Created by Kynan Song on 08/07/2018.
//  Copyright © 2018 Kynan Song. All rights reserved.
//  Learning from Brian Voong youtube video.

import UIKit
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        let captureSession = AVCaptureSession()
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        //if device has no camera use try with a ? to avoid errors and guard statements to unwrap the optionals.
        //Need to set privacy settings in info.plist
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

