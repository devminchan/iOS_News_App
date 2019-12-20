//
//  ImageInfo.swift
//  CocoaHeroes
//
//  Created by 김민찬 on 2019/12/20.
//  Copyright © 2019 김민찬. All rights reserved.
//
import ObjectMapper

class ImageInfo: Mappable {
    var collection: String?
    var thumbnailUrl: String?
    var imageUrl: String?
    var displaySitename: String?
    var docUrl: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        collection <- map["collection"]
        thumbnailUrl <- map["thumbnail_url"]
        imageUrl <- map["image_url"]
        displaySitename <- map["display_sitename"]
        docUrl <- map["doc_url"]
    }
}
