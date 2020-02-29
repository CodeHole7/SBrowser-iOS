//
//  GlobalObjects.swift
//  SBrowser
//
//  Created by Jin Xu on 21/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation


let kWebViewFinishOrError = "WebViewFinishOrErrorSB"
let kAddNewBlankTab = "AddNewBlankTabSB"
let kOldHisotries = "OldHisotriesSB"
let kHomePage = "HomePageSB"

let rootviewController = UIApplication.shared.keyWindow!.rootViewController as! BrowserViewController
var shouldRedirectAfterCertImport = false
var redirecturl:URL?
class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = try! URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                print("######################TEMP \(tempLocalUrl)")
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                    DispatchQueue.main.async {
                        rootviewController.HideBlackLayer()
                    }
                }

            } else {
                print("Failure: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
}
func decryptLength(sourceCount l: Int) -> Int {
    return l
}
func decrypt(_ data: UnsafeRawBufferPointer, key: UnsafeRawBufferPointer, iv: UnsafeRawBufferPointer) -> UnsafeMutableRawBufferPointer? {
    guard let ctx = EVP_CIPHER_CTX_new(),
        let keyBase = key.baseAddress,
        let ivBase = iv.baseAddress else {
            return nil
    }
    defer {
        EVP_CIPHER_CTX_free(ctx)
    }
    guard 1 == EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), nil,
                                  keyBase.assumingMemoryBound(to: UInt8.self),
                                  ivBase.assumingMemoryBound(to: UInt8.self)) else {
                                    return nil
    }
    let allocLength = decryptLength(sourceCount: data.count-1)
    let dstPtr = UnsafeMutableRawBufferPointer.allocate(byteCount: allocLength, alignment: 0)
    var wroteLength = Int32(0)
    guard 1 == EVP_DecryptUpdate(ctx,
                                 dstPtr.baseAddress?.assumingMemoryBound(to: UInt8.self),
                                 &wroteLength,
                                 data.baseAddress?.assumingMemoryBound(to: UInt8.self),
                                 Int32(data.count-1)) else {
                                    dstPtr.deallocate()
                                    return nil
    }
    let owroteLength = Int(wroteLength)
    guard 1 == EVP_DecryptFinal(ctx,
                                dstPtr.baseAddress?.assumingMemoryBound(to: UInt8.self).advanced(by: Int(wroteLength)),
                                &wroteLength) else {
                                    dstPtr.deallocate()
                                    return nil
    }
    let iwroteLength = Int(wroteLength) + owroteLength
    if iwroteLength < allocLength {
        let newDstPtr = UnsafeMutableRawBufferPointer.allocate(byteCount: iwroteLength, alignment: 0)
        memcpy(newDstPtr.baseAddress!, dstPtr.baseAddress!, iwroteLength)
        dstPtr.deallocate()
        return newDstPtr
    }
    return dstPtr
}
func pathForTemporaryFile(withPrefix prefix: String?) -> String? {
    var result = ""
    var uuid: CFUUID?
    var uuidStr: CFString?

    uuid = CFUUIDCreate(nil)

    uuidStr = CFUUIDCreateString(nil, uuid)

    if let uuidStr = uuidStr {
        result = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(prefix ?? "")-\(uuidStr)").path
    }


    return result
}
