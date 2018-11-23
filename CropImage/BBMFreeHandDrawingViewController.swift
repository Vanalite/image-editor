//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class BBMFreeHandDrawingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var colorPickerCollectionView: UICollectionView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var selectedColorButton: UIButton!
    @IBOutlet weak var brushWidthSlider: VerticalSlider!
    @IBOutlet weak var bottomView: UIView!
    
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
         self.hideControls()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.showControls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.image
        self.drawController = FreehandDrawController(canvas: self.imageView, view: self.imageView)
        self.drawController.color = self.colorArray.first!
        self.setupUI()
        self.selectedColorButton.backgroundColor = self.drawController.color
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    fileprivate func showControls() {
        UIView.animate(withDuration: 0.5) {
            self.bottomView.layer.opacity = 1
            self.brushWidthSlider.layer.opacity = 1
        }
    }
    
    fileprivate func hideControls() {
        UIView.animate(withDuration: 0.5) {
            self.bottomView.layer.opacity = 0
            self.brushWidthSlider.layer.opacity = 0
        }
    }
    
    fileprivate func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.selectedColorButton.layer.cornerRadius = self.selectedColorButton.frame.width / 2
        self.selectedColorButton.layer.masksToBounds = true
        self.setupImageView()
        self.setupBrushWidthSlider()
    }

    fileprivate func setupImageView() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageContainerView.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageContainerView)
    }
    
    fileprivate func setupBrushWidthSlider() {
        self.brushWidthSlider.slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        self.brushWidthSlider.value = Float(self.drawController.width)
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
    
    @objc func sliderChanged() {
        self.drawController.width = CGFloat(self.brushWidthSlider.value)
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
