//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Anton Belousov on 01/09/15.
//  Copyright © 2015 novilab-mobile. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let photoPickerAdapter = GetPhotoAdapter()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func getPhotoButtonPressed(sender: AnyObject) {
        photoPickerAdapter.showAvailablePhotoSourcesPicker{
            [unowned self]
            image in
            print("FUNC: \(__FUNCTION__), LINE: \(__LINE__)")
            self.imageView.image = image
        }
    }
    
    @IBAction func goToSettingsButtonPressed(sender: AnyObject) {
    
        let alertController = UIAlertController (title: "Title", message: "Go to Settings?", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil);
        
    }
}

