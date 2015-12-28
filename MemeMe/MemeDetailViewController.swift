//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Kalpesh Balar on 27/12/15.
//  Copyright © 2015 Kalpesh Balar. All rights reserved.
//

import UIKit

class MemeDetailViewController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.label.text = self.meme.topText
        
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
}