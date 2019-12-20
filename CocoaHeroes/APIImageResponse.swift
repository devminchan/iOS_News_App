//
//  APIResponse.swift
//  CocoaHeroes
//
//  Created by 김민찬 on 2019/12/20.
//  Copyright © 2019 김민찬. All rights reserved.
//
import ObjectMapper

class APIImageResponse: Mappable {
    var meta: MetaData?
    var documents: [ImageInfo] = []
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        meta <- map["meta"]
        documents <- map["documents"]
    }
}

class MetaData: Mappable {
    var totalCount: Int?
    var pageableCount: Int?
    var isEnd: Bool?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        totalCount <- map["total_count"]
        pageableCount <- map["pageable_count"]
        isEnd <- map["is_end"]
    }
}
