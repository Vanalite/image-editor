//
//  ImagePreviewViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    var image = UIImage(named: "Image2")

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = self.image
    }
    
    @IBAction func drawButtonTouched(_ sender: Any) {
        self.performSegue(withIdentifier: "freeHandSegue", sender: self)
    }
    
    @IBAction func cropButtonTouched(_ sender: Any) {
        self.performSegue(withIdentifier: "cropSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! ==  "freeHandSegue" {
            if let vc = segue.destination as? BBMFreeHandDrawingViewController {
                vc.image = self.image
            }
        } else {
            if let vc: BBMCropRotateImageViewController = segue.destination as? BBMCropRotateImageViewController {
                vc.image = self.image
            }

        }
    }
    
}
