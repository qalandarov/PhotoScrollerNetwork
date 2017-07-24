//
//  PhotoDetailsViewController.swift
//  PSNCopy
//
//  Created by Islam Qalandarov on 7/23/17.
//  Copyright © 2017 Qalandarov. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageName: String!
    var decoder: imageDecoder!
    var isWebTest = false
    
    fileprivate var tiler: TiledImageBuilder?
    fileprivate var startTime: UInt64 = 0
    fileprivate var operationsRunner: OperationsRunner?
    
    private var elapsedTime: UInt64 {
        let finishTime = mach_absolute_time()
        return deltaMAT(from: startTime, till: finishTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard decoder != nil && imageName != nil else {
            assertionFailure("Properties are not set properly")
            return
        }
        
        startTime = mach_absolute_time()
        
        if isWebTest {
            prepareNetworkMode()
            fetchWebImages()
        } else {
            constructStaticImages()
        }
    }
    
    fileprivate func updateUI() {
        spinner.stopAnimating()
        tilePages()
        title = "DecodeTime: \(elapsedTime) ms"
    }
    
    private func deltaMAT(from start: UInt64, till finish: UInt64) -> UInt64 {
        var delta = finish - start
        
        /* Get the timebase info */
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        
        /* Convert to nanoseconds */
        delta *= UInt64(info.numer)
        delta /= UInt64(info.denom)
        
        return UInt64(Double(delta) / 1e6) // ms
    }
    
}


// MARK: - Networking

extension PhotoDetailsViewController {
    
    fileprivate func prepareNetworkMode() {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.httpShouldSetCookies = true
        config.httpShouldUsePipelining = true
        
        OperationsRunner.createSharedSession(with: config, delegate: ORSessionDelegate())
        
        operationsRunner = OperationsRunner(delegate: self)
    }
    
    fileprivate func fetchWebImages() {
        let path = "https://www.dropbox.com/s/w0s5905cqkcy4ua/Space5.jpg?dl=1"
        
        let operation = ConcurrentOp()
        operation.urlStr = path
        operation.decoder = decoder
        operation.index = 0
        operation.orientation = 0
        
        operationsRunner?.runOperation(operation, withMsg: path)
    }
    
}

extension PhotoDetailsViewController: OperationsRunnerProtocol {
    func operationFinished(_ op: ORWebFetcher!, count remainingOps: UInt) {
        guard let operation = op as? ConcurrentOp, let tiler = operation.imageBuilder else {
            assertionFailure("Operation object is corrupt")
            return
        }
        
        self.tiler = tiler
        
        if remainingOps == 0 {
            updateUI()
        }
    }
}


// MARK: - Tiling

extension PhotoDetailsViewController {
    
    fileprivate func constructStaticImages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let path = Bundle.main.path(forResource: self.imageName, ofType: "jpg")
            self.tiler = TiledImageBuilder(imagePath: path,
                                           withDecode: self.decoder,
                                           size: CGSize(width: 320, height: 320),
                                           orientation: 0)
            
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
    fileprivate func tilePages() {
        let page = ImageScrollView()
        page.aspectFill = true
        page.frame = view.bounds
        page.display(tiler)
        view.addSubview(page)
    }
    
}
