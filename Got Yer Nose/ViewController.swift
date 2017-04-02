//
//  ViewController.swift
//  Got Yer Nose
//
//  Created by Adam Cobb on 4/1/17.
//  Copyright © 2017 Daddy. All rights reserved.
//

import UIKit
import Photos
import ProjectOxfordFace

class ViewController: UIViewControllerX, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static weak var context:ViewController!
    
    static func typefaceR(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Book", size: size)!}
    static func typefaceRI(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-BookOblique", size: size)!}
    static func typefaceM(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Heavy", size: size)!}
    static func typefaceMI(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-HeavyOblique", size: size)!}
    static func typefaceB(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Black", size: size)!}
    
    let detectionClient = MPOFaceServiceClient(subscriptionKey: "e0277c910dbe468783e0fd3ac62c1794")

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!
    
    @IBOutlet weak var baseFailedView: UIView!
    @IBOutlet weak var chooseImageView: UIView!
    @IBOutlet weak var chooseImageText: UILabel!
    @IBOutlet weak var preloadedImages: UIView!
    @IBOutlet weak var selectFeaturesView: UIView!
    @IBOutlet weak var featuresStack: UIStackView!
    @IBOutlet weak var workingView: UIView!
    @IBOutlet weak var workingSpinner: UIActivityIndicatorView!
    
    var baseFace:MPOFace!
    var switchingImage = true
    var grabbedImage:UIImage!
    var grabbedFace:MPOFace!
    
    @IBOutlet weak var baseFailedText: UILabel!
    @IBAction func switchImageClick(_ sender: Any) {
        switchingImage = true
        
        chooseImageView.isHidden = false
        chooseImageText.text = "Choose a Base Image"
    }
    
    @IBAction func grabFeatureClick(_ sender: Any) {
        switchingImage = false
        
        chooseImageView.isHidden = false
        chooseImageText.text = "Choose an Image to Grab Features From"
    }
    @IBAction func downloadClick(_ sender: Any) {
        Toast.makeText(self, "Downloading image...", Toast.LENGTH_SHORT)
    }
    @IBAction func undoClick(_ sender: Any) {
    }
    @IBAction func redoClick(_ sender: Any) {
    }
    @IBAction func chooseFromGalleryClick(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)
    }
    @IBAction func imageClick(_ sender: UIButton) {
        if switchingImage{
            didSelectNewBaseImage(image: sender.currentImage!)
        }else{
            didSelectNewGrabImage(image: sender.currentImage!)
        }
    }
    
    @IBAction func featureClick(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "ic_check_box_outline_blank"){
            sender.setImage(#imageLiteral(resourceName: "ic_check_box"), for: .normal)
        }else{
            sender.setImage(#imageLiteral(resourceName: "ic_check_box_outline_blank"), for: .normal)
        }
    }
    
    @IBAction func cancelChooseClick(_ sender: Any) {
        chooseImageView.isHidden = true
        selectFeaturesView.isHidden = true
    }
    
    @IBAction func applyFeatures(_ sender: Any) {
        
        beginWorking()
        
        var image = mainImageView.image!
        
        Async.run(Async.PRIORITY_IMPORTANT, AsyncSyncInterface(runTask: {
            let imageSize = image.size
            let scale: CGFloat = 0
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
            let context = UIGraphicsGetCurrentContext()!
            
            image.draw(at: .zero)
            
            var count = 0
            for subview in self.featuresStack.subviews{
                count += 1
                if (subview as! UIButton).currentImage == #imageLiteral(resourceName: "ic_check_box"){
                    self.applyFeature(count, context)
                }
            }
            image = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }, afterTask: {
            self.mainImageView.image = image
            self.chooseImageView.isHidden = true
            self.selectFeaturesView.isHidden = true
            self.endWorking()
        }))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.context = self
        
        workingSpinner.roundCorners(corners: .allCorners, radius: 16)
        workingSpinner.startAnimating()
        
        for subview in preloadedImages.subviews{
            (subview as! UIButton).imageView?.contentMode = .scaleAspectFit
        }
        
        didSelectNewBaseImage(image: Files.readImage("currentImage", #imageLiteral(resourceName: "rupaul-allstars-750x563")))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if switchingImage{
                didSelectNewBaseImage(image: image)
            }else{
                didSelectNewGrabImage(image: image)
            }
        }else{
            Toast.makeText(self, "Error receiving image.", Toast.LENGTH_LONG)
        }
        switchingImage = false
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    func beginWorking(){
        workingView.isHidden = false
    }
    
    func endWorking(){
        workingView.isHidden = true
    }
    
    func didSelectNewBaseImage(image:UIImage){
        beginWorking()
        baseFailedView.isHidden = true
        undo.isEnabled = false
        redo.isEnabled = false
        
        var image = image
        
        if image.size.width > image.size.height && image.size.width > 1024{
            image = image.scaleImage(toSize: CGSize(width: 1024, height: 1024 * image.size.height / image.size.width))
        }else if image.size.height > image.size.width && image.size.height > 1024{
            image = image.scaleImage(toSize: CGSize(width: 1024 * image.size.width / image.size.height, height: 1024))
        }
        
        let _ = detectionClient?.detect(with: UIImageJPEGRepresentation(image, 1)!, returnFaceId: false, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeHeadPose.rawValue], completionBlock: { (faces, error) in
            if error == nil{
                if let faces = faces{
                    if faces.count == 0{
                        self.baseImageFailed(message: "No faces were detected.\nPlease try a new base image\nfrom your gallery.")
                    }else{
                        let face = faces.first!
                        self.baseFace = faces.first!
                        self.mainImageView.image = image
                        
                        print("Nic Cage is located at (l,t,w,h) = (" + face.faceRectangle.left.description + "," + face.faceRectangle.top.description + "," + face.faceRectangle.width.description + "," + face.faceRectangle.height.description + ")")
                        print("roll, pitch, yaw: " + face.attributes.headPose.roll.description + "," + face.attributes.headPose.pitch.description + "," + face.attributes.headPose.yaw.description)
                        let eyeRect = CGRect(x: CGFloat(face.faceLandmarks.eyeLeftOuter.x), y: CGFloat(face.faceLandmarks.eyeLeftTop.y), width: CGFloat(face.faceLandmarks.eyeLeftInner.x) - CGFloat(face.faceLandmarks.eyeLeftOuter.x), height: CGFloat(face.faceLandmarks.eyeLeftBottom.y) - CGFloat(face.faceLandmarks.eyeLeftTop.y))
                        self.mainImageView.image = self.drawRectangleOnImage(image: image, rect: eyeRect/*CGRect(faceRect: face.faceRectangle)*/, angle: 0/*CGFloat(face.attributes.headPose.roll) * CGFloat.pi / 180*/)
                    }
                }else{
                    self.baseImageFailed(message: "Failed to initialize face detection.\nPlease select an image from your gallery\nto try again.")
                }
            }else{
                self.baseImageFailed(message: "Failed to initialize face detection due to the error below.  Please select an image from your gallery to try again.\n\nError message:\n" + error!.localizedDescription)
            }
            self.chooseImageView.isHidden = true
            self.endWorking()
        })
    }
    
    func baseImageFailed(message:String){
        baseFailedView.isHidden = false
        baseFailedText.text = message
    }
    
    func didSelectNewGrabImage(image:UIImage){
        beginWorking()
        
        var image = image
        
        if image.size.width > image.size.height && image.size.width > 1024{
            image = image.scaleImage(toSize: CGSize(width: 1024, height: 1024 * image.size.height / image.size.width))
        }else if image.size.height > image.size.width && image.size.height > 1024{
            image = image.scaleImage(toSize: CGSize(width: 1024 * image.size.width / image.size.height, height: 1024))
        }
        
        let _ = detectionClient?.detect(with: UIImageJPEGRepresentation(image, 1)!, returnFaceId: false, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeHeadPose.rawValue], completionBlock: { (faces, error) in
            if error == nil{
                if let faces = faces{
                    if faces.count == 0{
                        Toast.makeText(self, "No faces were detected.\nPlease try again with a new image.", Toast.LENGTH_LONG)
                    }else{
                        self.grabbedFace = faces.first!
                        self.grabbedImage = image
                        self.chooseImageView.isHidden = true
                        self.selectFeaturesView.isHidden = false
                        for subview in self.featuresStack.subviews{
                            (subview as! UIButton).setImage(#imageLiteral(resourceName: "ic_check_box_outline_blank"), for: .normal)
                        }
                    }
                }else{
                    Toast.makeText(self, "Failed to initialize face detection.\nPlease try again.", Toast.LENGTH_LONG)
                }
            }else{
                Toast.makeText(self, "Failed to initialize face detection due to the error below.  Please try again.\n\nError message:\n" + error!.localizedDescription, Toast.LENGTH_LONG)
            }
            self.endWorking()
        })

    }
    
    func applyFeature(_ featureNum:Int, _ context:CGContext){
        
    }
    
    func coordinatesOfFeature(_ featureNum:Int, on face:MPOFace){
        
    }
    
    func drawRectangleOnImage(image: UIImage, rect: CGRect, angle:CGFloat) -> UIImage {
        let imageSize = image.size
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        
        image.draw(at: .zero)
        //Color("#44ac1997").setFill()
        //UIRectFill(rect)
        
        context.saveGState();
        
        let halfWidth = rect.width / 2.0;
        let halfHeight = rect.height / 2.0;
        let center = CGPoint(x: rect.origin.x + halfWidth, y: rect.origin.y + halfHeight);
        
        // Move to the center of the rectangle:
        context.translateBy(x: center.x, y: center.y);
        // Rotate:
        context.rotate(by: angle);
        // Draw the rectangle centered about the center:
        let newRect = CGRect(x:-halfWidth, y:-halfHeight, width:rect.width, height:rect.height);
        context.addRect(newRect);
        context.setStrokeColor(Color.yellow.cgColor)
        context.strokePath();
        
        context.restoreGState();
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return newImage
    }

}

