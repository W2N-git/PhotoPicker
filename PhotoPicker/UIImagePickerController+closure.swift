//
//  UIImagePickerController+closure.swift
//  PhotoPicker
//
//  Created by qqqqq on 02/09/15.
//  Copyright © 2015 novilab-mobile. All rights reserved.
//

import UIKit

class UIImagePickerControllerActionHandler:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var action : (UIImage?) -> () = {_ in}
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("FUNC: \(__FUNCTION__), LINE:\(__LINE__), image size: \(image.size)")
            self.action(image)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("FUNC: \(__FUNCTION__), LINE:\(__LINE__)")
        self.action(nil)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UIImagePickerController {
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }

    var actionHandler: UIImagePickerControllerActionHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? UIImagePickerControllerActionHandler
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.DescriptiveName,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func setImagePickerAction(action: (UIImage?) -> ()) {
        if let actionHandler = self.actionHandler {
            actionHandler.action = action
            return
        }
        let actionHandler    = UIImagePickerControllerActionHandler()
        actionHandler.action = action
        self.delegate        = actionHandler
        self.actionHandler   = actionHandler
    }
}
