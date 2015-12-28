//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Kalpesh Balar on 10/12/15.
//  Copyright © 2015 Kalpesh Balar. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSStrokeWidthAttributeName : 1.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.enabled = false
        cancelButton.enabled = false
        prepareTextFields(topText, initailText: "TOP")
        prepareTextFields(bottomText, initailText: "BOTTOM")
    }

    func prepareTextFields(textField: UITextField, initailText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = initailText
        textField.textAlignment = NSTextAlignment.Center
        textField.delegate = self
        textField.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func imagePicker(sender: UIBarButtonItem) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        presentViewController(imageController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        print("start Share Action")
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareController.completionWithItemsHandler = {
            (activity, success, items, error) in
            self.saveMeme(memedImage)
            self.dismissViewControllerAnimated(true, completion: {});

        }
        presentViewController(shareController, animated: true, completion: nil)
    }
    
    @IBAction func cameraAction(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            presentViewController(cameraController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage

            cancelButton.enabled = true
            shareButton.enabled = true
            topText.enabled = true
            bottomText.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (bottomText.isFirstResponder()) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (bottomText.isFirstResponder()) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func textFieldDidBeginEditing(_textField: UITextField) {
        _textField.text = ""
    }
    
    func textFieldShouldReturn(_textField: UITextField) -> Bool {
        _textField.resignFirstResponder()
        return true
    }
    
    func generateMemedImage() -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func saveMeme(image: UIImage) {
        let meme = Meme(topText: (topText.text)!, bottomText: (bottomText.text)!, image: (imageView.image)!, memedImage: image)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        print("Meme Saved")
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        
        topText.enabled = false
        bottomText.enabled = false
        imageView.image = nil
        
        cancelButton.enabled = false
        shareButton.enabled = false
    }
}