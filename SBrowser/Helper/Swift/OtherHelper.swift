//
//  OtherHelper.swift
//  SBrowser
//
//  Created by Jin Xu on 29/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import Foundation

struct HistoryItem: Equatable {
    var url: URL?
    var title: String?
    
    init(){}
    
    init(url: URL?, title: String?) {
        self.url = url
        self.title = title
    }
    
    init(dictionary: NSDictionary) {
        if let path = dictionary.value(forKey: "path") as? String {
            url = URL(string: path)
        }
        if let titleVal = dictionary.value(forKey: "title") as? String {
            title = titleVal
        }
    }
    
    func getHistoryDictionary() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        if let urlObj = url {
            dict.setValue(urlObj.absoluteString, forKey: "path")
        }
        if let titleObj = title {
            dict.setValue(titleObj, forKey: "title")
        }
        return dict
    }
    
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.url == rhs.url && lhs.title == rhs.title
    }
}
