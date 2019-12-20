//
//  ViewController.swift
//  PodPod
//
//  Created by 김민찬 on 2019/12/19.
//  Copyright © 2019 김민찬. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ViewController: UIViewController {

    @IBOutlet weak var cocoaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queryDict = ["query": "설현"]
        let headers = [
            "Authorization": "KakaoAK d3994f8190b66a9d3e493928bd27bd16",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire
            .request("https://dapi.kakao.com/v2/search/image",
                     method: .get,
                     parameters: queryDict,
                     headers: headers).responseObject
            { (res: DataResponse<APIImageResponse>) in
                switch (res.result) {
                case .success(let result):
                    result.documents.forEach { imageInfo in
                        print(imageInfo.collection ?? "")
                    }
                case .failure(let err):
                    debugPrint(err.localizedDescription)
                }
        }
    }
}
