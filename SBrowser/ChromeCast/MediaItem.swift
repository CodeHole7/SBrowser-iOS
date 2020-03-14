//
//  MediaItem.swift
//  SBrowser
//
//  Created by Jin Xu on 13/03/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleCast

class MediaItem: NSObject {

    fileprivate(set) var url: URL?
    fileprivate(set) var title: String?
    fileprivate(set) var subTitle: String?
    fileprivate(set) var imageURL: URL?
    fileprivate(set) var mediaInformation: GCKMediaInformation?
    fileprivate(set) var streamType = GCKMediaStreamType.none
    fileprivate(set) var contentType = "video/mp4"
    
    init(url: URL, title: String?, subTitle: String?, imageURL: URL?) {
        self.url = url
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
        
        
        let metadata = GCKMediaMetadata()
        if let title = title {
            metadata.setString(title, forKey: kGCKMetadataKeyTitle)
        }
        if let subTitle = subTitle {
            metadata.setString(subTitle, forKey: kGCKMetadataKeySubtitle)
        }
        if let imageURL = imageURL {
            metadata.addImage(GCKImage(url: imageURL,
                                       width: 480,
                                       height: 360))
        } else {
            
            //Get Thumbnail
            var thumbImage: UIImage?
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                thumbImage = UIImage(cgImage: cgThumbImage) //7
                
            } catch {
                print(error.localizedDescription) //10
                
            }
            
            //Remove Previous saved image
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let imageURL = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("tmpCast.png")
                
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    try? FileManager.default.removeItem(atPath: imageURL.path)
                }
            }
            
            //Save Image to disk
            if let imageSaved = thumbImage {
                if saveImage(image: imageSaved) {
                    //Get image from disk
                    if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                        let imageURL = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("tmpCast.png")
                        
                        //Set disk image url to GCK
                        metadata.addImage(GCKImage(url: imageURL,
                        width: 480,
                        height: 360))
                    }
                }
            }
            
            
        }
        
        if url.pathExtension == "m3u8" {
            contentType = "video/m3u"
        }
        

        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
        mediaInfoBuilder.streamType = streamType
        mediaInfoBuilder.contentType = contentType
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()
        
    }
    
}




func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
    DispatchQueue.global().async { //1
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 25, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbImage = UIImage(cgImage: cgThumbImage) //7
            DispatchQueue.main.async { //8
                completion(thumbImage) //9
            }
        } catch {
            print(error.localizedDescription) //10
            DispatchQueue.main.async {
                completion(nil) //11
            }
        }
    }
}

func saveImage(image: UIImage) -> Bool {
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return false
    }
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
        return false
    }
    do {
        try data.write(to: directory.appendingPathComponent("tmpCast.png")!)
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}
