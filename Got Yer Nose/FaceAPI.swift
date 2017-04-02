//
//  FaceAPI.swift
//  Got Yer Nose
//
//  Created by Adam Cobb on 4/1/17.
//  Copyright © 2017 Daddy. All rights reserved.
//

import Foundation
import ProjectOxfordFace

extension CGRect{
    init(faceRect:MPOFaceRectangle){
        self.init(x: CGFloat(faceRect.left), y: CGFloat(faceRect.top), width: CGFloat(faceRect.width), height: CGFloat(faceRect.height))
    }
}

class FaceAPI:AnyObject {
    // Detect faces
    
    enum Err: Error {
        case UnexpectedError(nsError: Error?)
        case ServiceError(json: [String: AnyObject])
        case JSonSerializationError
    }
    
    typealias JSON = Any
    typealias JSONDictionary = [String: JSON]
    typealias JSONArray = [JSON]

    
    enum FaceAPIResult<T, Error> {
        case Success(T)
        case Failure(Error)
    }
    
    static func detectFaces(facesPhoto: UIImage, completion: @escaping (FaceAPIResult<JSON, Err>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("e0277c910dbe468783e0fd3ac62c1794", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(facesPhoto)
        
        let task = URLSession.shared.uploadTask(with: request, from: pngRepresentation) { (data, response, error) in
            
            if let nsError = error {
                completion(.Failure(Err.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        completion(.Success(json))
                    }
                    else {
                        completion(.Failure(Err.ServiceError(json: json as! [String : AnyObject])))
                    }
                }
                catch {
                    completion(.Failure(Err.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
}
