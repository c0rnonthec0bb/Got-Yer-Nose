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
    
    var undos:[UIImage] = []
    var redos:[UIImage] = []
    
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
        Toast.makeText(self, "Saving image...", Toast.LENGTH_SHORT)
        UIImageWriteToSavedPhotosAlbum(mainImageView.image!, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    //added as iOS callback func
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil{
            Async.toast("Successfully saved image.", true);
        }else{
            Async.toast("Failed to save image.", true);
        }
    }
    @IBAction func undoClick(_ sender: Any) {
        redo.isEnabled = true
        redos.append(mainImageView.image!)
        mainImageView.image = undos.popLast()!
        if undos.isEmpty{
            undo.isEnabled = false
        }
    }
    @IBAction func redoClick(_ sender: Any) {
        undo.isEnabled = true
        undos.append(mainImageView.image!)
        mainImageView.image = redos.popLast()!
        if redos.isEmpty{
            redo.isEnabled = false
        }
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
            self.undo.isEnabled = true
            self.undos.append(self.mainImageView.image!)
            
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
        
        didSelectNewBaseImage(image: Files.readImage("currentImage", #imageLiteral(resourceName: "rupaul")))
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
        undos = []
        redos = []
        
        var image = image
        
        if image.size.width > image.size.height && image.size.width > 2048{
            image = image.scaleImage(toSize: CGSize(width: 2048, height: 2048 * image.size.height / image.size.width))
        }else if image.size.height > image.size.width && image.size.height > 2048{
            image = image.scaleImage(toSize: CGSize(width: 2048 * image.size.width / image.size.height, height: 2048))
        }
        
        let _ = detectionClient?.detect(with: UIImageJPEGRepresentation(image, 1)!, returnFaceId: false, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeHeadPose.rawValue], completionBlock: { (faces, error) in
            if error == nil{
                if let faces = faces{
                    if faces.count == 0{
                        self.baseImageFailed(message: "No faces were detected.\nPlease try a new base image\nfrom your gallery.")
                    }else{
                        self.baseFace = faces.first!
                        self.mainImageView.image = image
                        Files.writeImage("currentImage", image)
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
        
        if image.size.width > image.size.height && image.size.width > 2048{
            image = image.scaleImage(toSize: CGSize(width: 2048, height: 2048 * image.size.height / image.size.width))
        }else if image.size.height > image.size.width && image.size.height > 2048{
            image = image.scaleImage(toSize: CGSize(width: 2048 * image.size.width / image.size.height, height: 2048))
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
        let originCoords = coordinatesOfFeature(featureNum, on: grabbedFace)
        let destinationCoords = coordinatesOfFeature(featureNum, on: baseFace)
        
        let imageSize = originCoords.size
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let newContext = UIGraphicsGetCurrentContext()!
        newContext.translateBy(x: originCoords.size.width / 2, y: originCoords.size.height / 2)
        newContext.rotate(by: -originCoords.rotation)
        grabbedImage.draw(at: .zero - originCoords.center)
        let snippet = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsPopContext()
        
        context.saveGState();
        context.translateBy(x: destinationCoords.center.x, y: destinationCoords.center.y)
        context.rotate(by: destinationCoords.rotation)
        snippet.draw(in: CGRect(origin: CGPoint(x: -destinationCoords.size.width / 2, y: -destinationCoords.size.height / 2), size: destinationCoords.size))
        context.restoreGState()
    }
    
    func coordinatesOfFeature(_ featureNum:Int, on face:MPOFace)->(center:CGPoint, size:CGSize, rotation:CGFloat){
        var center:CGPoint!
        var size:CGSize!
        var rotation:CGFloat!
        
        switch featureNum{
        case 1: //left eyebrow
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.eyebrowLeftOuter.x), y: CGFloat(face.faceLandmarks.eyebrowLeftOuter.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.eyebrowLeftInner.x), y: CGFloat(face.faceLandmarks.eyebrowLeftInner.y))
            let a = (p1 - p2) / 8
            center = (p1 + p2) / 2 + CGPoint(x: a.y, y: a.x)
            let w = hypot(p2 - p1) * 1.4
            size = CGSize(width: w, height: w / 4)
            rotation = atan((p2.y - p1.y) / (p2.x - p1.x))
            break
        case 2: //right eyebrow
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.eyebrowRightInner.x), y: CGFloat(face.faceLandmarks.eyebrowRightInner.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.eyebrowRightOuter.x), y: CGFloat(face.faceLandmarks.eyebrowRightOuter.y))
            let a = (p1 - p2) / 8
            center = (p1 + p2) / 2 + CGPoint(x: a.y, y: a.x)
            let w = hypot(p2 - p1) * 1.4
            size = CGSize(width: w, height: w / 4)
            rotation = atan((p2.y - p1.y) / (p2.x - p1.x))
            break
        case 3: //left eye
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.eyeLeftOuter.x), y: CGFloat(face.faceLandmarks.eyeLeftOuter.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.eyeLeftInner.x), y: CGFloat(face.faceLandmarks.eyeLeftInner.y))
            let a = (p1 - p2) / 12
            center = (p1 + p2) / 2 + CGPoint(x: a.y, y: a.x)
            let w = hypot(p2 - p1) * 1.5
            size = CGSize(width: w, height: w / 2)
            rotation = atan((p2.y - p1.y) / (p2.x - p1.x))
            break
        case 4: //right eye
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.eyeRightInner.x), y: CGFloat(face.faceLandmarks.eyeRightInner.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.eyeRightOuter.x), y: CGFloat(face.faceLandmarks.eyeRightOuter.y))
            let a = (p1 - p2) / 12
            center = (p1 + p2) / 2 + CGPoint(x: a.y, y: a.x)
            let w = hypot(p2 - p1) * 1.5
            size = CGSize(width: w, height: w / 2)
            rotation = atan((p2.y - p1.y) / (p2.x - p1.x))
            break
        case 5: //nose
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.noseLeftAlarOutTip.x), y: CGFloat(face.faceLandmarks.noseLeftAlarOutTip.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.noseRightAlarOutTip.x), y: CGFloat(face.faceLandmarks.noseRightAlarOutTip.y))
            let p3 = CGPoint(x: CGFloat(face.faceLandmarks.eyeLeftInner.x), y: CGFloat(face.faceLandmarks.eyeLeftInner.y))
            let p4 = CGPoint(x: CGFloat(face.faceLandmarks.eyeRightInner.x), y: CGFloat(face.faceLandmarks.eyeRightInner.y))
            let p12 = (p1 + p2) / 2
            let p34 = (p3 + p4) / 2
            center = (p34 * 0.7 + p12 * 1.3) / 2
            let w = hypot(p2 - p1) * 1.2
            let h = hypot(p12 - p34) * 1.2
            size = CGSize(width: w, height: h)
            rotation = atan(-(p34.x - p12.x) / (p34.y - p12.y))
            break
        case 6: //mouth
            let p1 = CGPoint(x: CGFloat(face.faceLandmarks.mouthLeft.x), y: CGFloat(face.faceLandmarks.mouthLeft.y))
            let p2 = CGPoint(x: CGFloat(face.faceLandmarks.mouthRight.x), y: CGFloat(face.faceLandmarks.mouthRight.y))
            let p3 = CGPoint(x: CGFloat(face.faceLandmarks.upperLipTop.x), y: CGFloat(face.faceLandmarks.upperLipTop.y))
            let p4 = CGPoint(x: CGFloat(face.faceLandmarks.underLipBottom.x), y: CGFloat(face.faceLandmarks.underLipBottom.y))
            //let a = (p2 - p1) / 8
            center = (p1 + p2 + p3 * 0.5 + p4 * 1.5) / 4
            let w = hypot(p2 - p1) * 1.5
            let h = hypot(p4 - p3) * 1.2
            size = CGSize(width: w, height: h)
            rotation = atan((p2.y - p1.y) / (p2.x - p1.x))
            break
        default: break
        }
        
        return (center, size, rotation)
    }

}

