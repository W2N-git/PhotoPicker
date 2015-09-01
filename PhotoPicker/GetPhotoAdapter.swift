//
//  TakeAPhotoAdapter.swift
//  oppeople
//
//  Created by Anton Belousov on 01/09/15.
//  Copyright © 2015 Oleg Shishin. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class GetPhotoAdapter: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var _currentPresentedViewController: UIViewController?
    
    var currentPresentedViewController: UIViewController? {
        set{
            _currentPresentedViewController = newValue
        }
        get{
            
            if let vc = _currentPresentedViewController {
                return vc
            }
            return UIApplication.sharedApplication().keyWindow?.rootViewController
        }
    }
    
    //MARK: - Types picking
    
    var availableProtoSources: [UIImagePickerControllerSourceType] {
        
        let types : [UIImagePickerControllerSourceType] = [
            .Camera,
            .PhotoLibrary,
            .SavedPhotosAlbum
        ]
        
        var availableTypes = [UIImagePickerControllerSourceType]()
        
        for type in types {
        
            if UIImagePickerController.isSourceTypeAvailable(type) {
                availableTypes.append(type)
            }
        }
        
        return availableTypes
    }
    
    func showAvailablePhotoSourcesPicker(completion: (UIImage?) -> ()) {
        
        //TODO: Move after source type chouse before picker view show
        
        self.showPermissionPromptIfNeeded()
        
        if self.availableProtoSources.count == 0 {
            self.showNoPhotoTypesAvailableMessage()
            return
        }
        
        let alertVC = UIAlertController(title: "choose_photo_source_title", message: "choose_photo_source_message", preferredStyle: .ActionSheet)
        
        for type in self.availableProtoSources {
        
            let action = UIAlertAction(title: "title_for_photo_source_type_\(type.rawValue)", style: UIAlertActionStyle.Default) {
                [unowned self]
                _ in
                self.getPhotoFromSource(type, completion: completion)
            }
            alertVC.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "cancel_action_title", style: UIAlertActionStyle.Cancel, handler: nil)
        alertVC.addAction(cancelAction)
        
        self.currentPresentedViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func showPermissionPromptIfNeeded() {
        
        //For Photo Library

        let libPermissionsStatus = ALAssetsLibrary.authorizationStatus()
        
        switch libPermissionsStatus {
        case .Authorized:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) everithing ok")
        case .Denied:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) should show alert")
            self.showPermissionPromtForSourceType(.PhotoLibrary)
        case let otherStatus:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) do not know what to do with this status: \(otherStatus.rawValue)")
        }
        
        
        //For Camera
        let status : AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo);
        
        switch status {
        case .Authorized:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) everithing ok")
        case .Denied:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) should show alert")
            self.showPermissionPromtForSourceType(.Camera)
        case let otherStatus:
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__) do not know what to do with this status: \(otherStatus.rawValue)")
        }
    }
    
    func showPermissionPromtForSourceType(type: UIImagePickerControllerSourceType) {
    
        let alertController = UIAlertController (title: "<##>", message: "<##>", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "<##>", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "<##>", style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.currentPresentedViewController?.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func showNoPhotoTypesAvailableMessage(){
        //MARK: - if user should be send to settings app, show such button
        let alertVC = UIAlertController(title: "no_access_to_photo_title", message: "no_access_to_photo_message", preferredStyle: .Alert)
        self.currentPresentedViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - Photo getting
    
    func getPhotoFromSource(source: UIImagePickerControllerSourceType, completion: (UIImage?) -> ()) {
    
        let imagePicker        = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate   = self
        self.currentPresentedViewController?.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("FUNC: \(__FUNCTION__), LINE:\(__LINE__)")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("FUNC: \(__FUNCTION__), LINE:\(__LINE__)")
    }
    
    
}

