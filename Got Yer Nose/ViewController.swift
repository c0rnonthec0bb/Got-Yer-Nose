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

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewController.context = self
        
        mainImageView.image = Files.readImage("currentImage", #imageLiteral(resourceName: "mrcage"))
        
        let client = MPOFaceServiceClient(subscriptionKey: "e0277c910dbe468783e0fd3ac62c1794")
        let _ = client?.detect(with: UIImagePNGRepresentation(#imageLiteral(resourceName: "mrcage"))!, returnFaceId: false, returnFaceLandmarks: true, returnFaceAttributes: [MPOFaceAttributeTypeHeadPose.rawValue], completionBlock: { (faces, error) in
            print("face detection returned!")
            if let faces = faces{
                if faces.count == 0{
                    Toast.makeText(self, "No faces were detected. Please try a new image.", Toast.LENGTH_LONG)
                }else{
                    let face = faces.first!
                    Toast.makeText(self, "Nic Cage is located at (l,t,w,h) = (" + face.faceRectangle.left.description + "," + face.faceRectangle.top.description + "," + face.faceRectangle.width.description + "," + face.faceRectangle.height.description + ")" , Toast.LENGTH_LONG)
                    print("roll, pitch, yaw: " + face.attributes.headPose.roll.description + "," + face.attributes.headPose.pitch.description + "," + face.attributes.headPose.yaw.description)
                }
            }else{
                Toast.makeText(self, "Face detection failed.  Please try again.", Toast.LENGTH_LONG)
            }
            print("size of array: " + (faces?.count.description ?? "nil"))
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchImageClick(_ sender: Any) {
        switchingImage = true
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func grabFeatureClick(_ sender: Any) {
    }
    @IBAction func downloadClick(_ sender: Any) {
        Toast.makeText(self, "Downloading image...", Toast.LENGTH_SHORT)
    }
    @IBAction func undoClick(_ sender: Any) {
    }
    @IBAction func redoClick(_ sender: Any) {
    }
    
    var switchingImage = false
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if switchingImage{
                
                mainImageView.image = image
            }else{
                //TODO Microsoft code
            }
        }else{
            Toast.makeText(self, "Error receiving image.", Toast.LENGTH_LONG)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }

}

