//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

@objc public protocol ImageEditorDelegate {
    func didFinishEditingImage(_ image: UIImage)
}

class BBMFreeHandDrawingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc weak var delegate : ImageEditorDelegate? = nil
    @IBOutlet weak var colorPickerCollectionView: UICollectionView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var selectedColorButton: UIButton!
    @IBOutlet weak var brushWidthSlider: VerticalSlider!
    @IBOutlet weak var bottomView: UIView!
    
    @objc public var image: UIImage! {
        didSet {
            self.imageView.originalImage = image
            if let cgImage = image.cgImage?.copy() {
                let newImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                self.imageView.image = newImage
            }
        }
    }
    let imageView = DrawableImageView()
    private var drawController: FreehandDrawController!
    let colorArray: [UIColor] = [.black, .red, .blue, .green, .yellow, .cyan, .magenta, .orange, .purple, .brown, .gray]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        self.drawController = FreehandDrawController(canvas: self.imageView, view: self.imageView)
        self.drawController.color = self.colorArray.first!
        self.setupUI()
        self.selectedColorButton.backgroundColor = self.drawController.color
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func rotated() {
        self.imageView.calibrateView()
    }
    
    override func viewDidLayoutSubviews() {
        self.imageView.calibrateView()
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
    
    fileprivate func dismiss() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        if let image = self.imageView.originalImage {
            self.delegate?.didFinishEditingImage(image)
        }
        self.dismiss()
    }
    
    @IBAction func undoButtonTouched(_ sender: Any) {
        self.drawController.undo()
    }
    
    @IBAction func saveButtonTouched(_ sender: Any) {
        if let image = self.imageView.image {
            self.delegate?.didFinishEditingImage(image)
        }
        self.dismiss()
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
