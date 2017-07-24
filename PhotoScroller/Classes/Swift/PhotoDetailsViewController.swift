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
    
    fileprivate var tiler: TiledImageBuilder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard decoder != nil && imageName != nil else {
            assertionFailure("Properties are not set properly")
            return
        }
        
        constructStaticImages()
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
                self.spinner.stopAnimating()
                self.tilePages()
                self.title = "Decode time: \(self.tiler?.milliSeconds ?? 0)"
            }
        }
    }
    
    private func tilePages() {
        let page = ImageScrollView()
        page.aspectFill = true
        page.frame = view.bounds
        page.display(tiler)
        view.addSubview(page)
    }
    
}
