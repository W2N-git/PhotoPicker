//
//  TakeAPhotoAdapter.swift
//  oppeople
//
//  Created by Anton Belousov on 01/09/15.
//  Copyright © 2015 Oleg Shishin. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AssetsLibrary

func IPC_LOC_STR(key:String) -> String {
    return NSLocalizedString(key, tableName: "ImagePickerLocalization", bundle: NSBundle(forClass: GetPhotoAdapter.self), comment: "")
}

func IPC_LOC_STR(key:String, type: UIImagePickerControllerSourceType) -> String  {

    let resultKey = key + "_" + type.description
    
    let value = IPC_LOC_STR(resultKey)
    
    if value == resultKey {
        return IPC_LOC_STR(key)
    }
    
    return value
}

enum AuthorizationStatus : Int {
    
    case NotDetermined // User has not yet made a choice with regards to this application
    case Restricted // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    case Denied // User has explicitly denied this application access to photos data.
    case Authorized // User has authorized this application to access photos data.
}

extension UIImagePickerControllerSourceType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Camera:
            return "Camera"
        case .PhotoLibrary:
            return "PhotoLibrary"
        case .SavedPhotosAlbum:
            return "SavedPhotosAlbum"
        }
    }
}

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
    
    var allSourceTypes: [UIImagePickerControllerSourceType] = [
        .PhotoLibrary,
        .Camera,
        .SavedPhotosAlbum
    ]
    
    var availableProtoSources: [UIImagePickerControllerSourceType] {
        return allSourceTypes.filter { UIImagePickerController.isSourceTypeAvailable($0) }
    }
    
    func showAvailablePhotoSourcesPicker(completion: (UIImage?) -> ()) {
        
        //TODO: Move after source type chouse before picker view show
        if self.availableProtoSources.count == 0 {
            self.showNoPhotoTypesAvailableMessage()
            return
        }
        
        let alertVC = UIAlertController(title: IPC_LOC_STR("choose_photo_source_title"), message: nil, preferredStyle: .ActionSheet)
        
        for type in self.availableProtoSources {
        
            let action = UIAlertAction(title: IPC_LOC_STR("photo_source_button_title", type: type), style: UIAlertActionStyle.Default) {
                [unowned self]
                _ in
                self.sourceTypeChoused(type, completion: completion)
            }
            alertVC.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: IPC_LOC_STR("cancel_button_title"), style: UIAlertActionStyle.Cancel, handler: nil)
        alertVC.addAction(cancelAction)
        
        self.currentPresentedViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func sourceTypeChoused(type: UIImagePickerControllerSourceType, completion: (UIImage?) -> ()) {
    
        switch self.authorizationStatusForSourceType(type) {
        case .NotDetermined:
            self.getPhotoFromSource(type, completion: completion)
        case .Authorized:
            self.getPhotoFromSource(type, completion: completion)
        case .Denied:
            self.showPermissionPromtForSourceType(type)
        case .Restricted:
            self.showPermissionRestrictedForSourceType(type)
        }
    }
    
    //MARK: - Source Type Auth Status
    
    func authorizationStatusForSourceType(type: UIImagePickerControllerSourceType) -> AuthorizationStatus {
    
        switch type {
        case .Camera:
            return self.authorizationStatusForCamera()
        default:
            return self.authorizationStatusForPhotoLibrary()
        }
    }
    
    func authorizationStatusForCamera() -> AuthorizationStatus {
        return AuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
    }
    
    func authorizationStatusForPhotoLibrary() -> AuthorizationStatus {
        return AuthorizationStatus(rawValue: ALAssetsLibrary.authorizationStatus().rawValue)!
    }
    
    //MARK: - Alerts

    func showPermissionRestrictedForSourceType(type: UIImagePickerControllerSourceType) {
        self.showAlert(IPC_LOC_STR("permission_restricted_title", type: type))
    }
    
    func showPermissionPromtForSourceType(type: UIImagePickerControllerSourceType) {
        self.showGoToSettingsAlert(IPC_LOC_STR("go_to_settings_title", type: type), message: IPC_LOC_STR("go_to_settings_message", type: type))
    }
    
    func showNoPhotoTypesAvailableMessage(){
        //MARK: - if user should be send to settings app, show such button
        self.showAlert(IPC_LOC_STR("no_access_to_photo_title"), message: IPC_LOC_STR("no_access_to_photo_message"))
    }
    
    //MARK: -
    
    func showAlert(title: String, message: String? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        self.currentPresentedViewController?.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    func showGoToSettingsAlert(title: String, message: String) {
    
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: IPC_LOC_STR("go_to_settings_button_title"), style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: IPC_LOC_STR("cancel_button_title"), style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.currentPresentedViewController?.presentViewController(alertController, animated: true, completion: nil);
    }
    
    //MARK: - Photo getting
    
    func getPhotoFromSource(source: UIImagePickerControllerSourceType, completion: (UIImage?) -> ()) {
    
        let imagePicker        = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.setImagePickerAction(completion)
        self.currentPresentedViewController?.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

