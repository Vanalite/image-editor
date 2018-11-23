//
//  BBMFreeHandDrawingViewController.swift
//  CropImage
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let freeHandImageName = "Image2"

class BBMFreeHandDrawingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var colorPickerCollectionView: UICollectionView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var selectedColorButton: UIButton!
    
    @objc public var image: UIImage! {
        didSet {
            self.imageView.image = image
            self.imageView.originalImage = image
        }
    }
    var originalImage: UIImage?
    let imageView = DrawableImageView()
    private var drawController: FreehandDrawController!
    let colorArray: [UIColor] = [.white, .black, .red, .blue, .green, .yellow, .cyan, .magenta, .orange, .purple, .brown]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.image
        self.setupUI()
        self.drawController = FreehandDrawController(canvas: self.imageView, view: self.imageView)
        self.drawController.color = self.colorArray.first!
        self.selectedColorButton.backgroundColor = self.drawController.color
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.selectedColorButton.layer.cornerRadius = self.selectedColorButton.frame.width / 2
        self.selectedColorButton.layer.masksToBounds = true
        self.setupImageView()
    }

    func setupImageView() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageContainerView.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageContainerView)
    }
    
    @IBAction func undoButtonTouched(_ sender: Any) {
        self.drawController.undo()
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        self.image = self.imageView.image
        if let vc = self.navigationController?.viewControllers.first as? ImagePreviewViewController {
            vc.image = self.image
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension BBMFreeHandDrawingViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerCellIdentifier", for: indexPath)
        cell.backgroundColor = self.colorArray[indexPath.item]
        cell.layer.cornerRadius = cell.contentView.frame.width / 2
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let cellColor = cell.backgroundColor {
            self.drawController.color = cellColor
            self.selectedColorButton.backgroundColor = cellColor
        }
    }
}
