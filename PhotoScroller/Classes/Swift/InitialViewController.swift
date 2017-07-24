//
//  InitialViewController.swift
//  PhotoScrollerNetwork
//
//  Created by Islam Qalandarov on 7/24/17.
//
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var networkSwitch: UISwitch!
    
    var imageName = "Space5"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoDetailsViewController {
            vc.imageName = imageName
            vc.decoder   = imageDecoder(rawValue: segmentedControl.selectedSegmentIndex)
            vc.isWebTest = networkSwitch.isOn
        }
    }

}
