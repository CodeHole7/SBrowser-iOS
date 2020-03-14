//
//  PKCS12.swift
//  SBrowser
//
//  Created by Jin Xu on 07/02/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

/**
 Struct representing values returned by `SecPKCS12Import` from the Security framework.
 
 This is what Cocoa and CocoaTouch can tell you about a PKCS12 file.
 
 */
public class PKCS12 {
    let label:String?
    let keyID:NSData?
    let trust:SecTrust?
    let certChain:[SecTrust]?
    let identity:SecIdentity?
    
    public init(PKCS12Data:NSData,password:String)
    {
        let importPasswordOption:NSDictionary = [kSecImportExportPassphrase as NSString:password]
        var items : CFArray?
        let secError:OSStatus = SecPKCS12Import(PKCS12Data, importPasswordOption, &items)
        
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                NSLog("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            }
            fatalError("SecPKCS12Import returned an error trying to import PKCS12 data")
        }
        
        
        guard let theItemsCFArray = items else { fatalError()  }
        let theItemsNSArray:NSArray = theItemsCFArray as NSArray
        guard let dictArray = theItemsNSArray as? [[String:AnyObject]] else { fatalError() }
        
        func f<T>(key:CFString) -> T? {
            for d in dictArray {
                if let v = d[key as String] as? T {
                    return v
                }
            }
            return nil
        }
        
        self.label = f(key: kSecImportItemLabel)
        self.keyID = f(key: kSecImportItemKeyID)
        self.trust = f(key: kSecImportItemTrust)
        self.certChain = f(key: kSecImportItemCertChain)
        self.identity =  f(key: kSecImportItemIdentity)
    }
}

extension URLCredential {
    public convenience init?(PKCS12 thePKCS12:PKCS12) {
        if let identity = thePKCS12.identity {
            self.init(
                identity: identity,
                certificates: thePKCS12.certChain,
                persistence: URLCredential.Persistence.forSession)
        }
        else { return nil }
    }
}
