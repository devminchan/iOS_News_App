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
import Kingfisher

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var imageInfoList: [ImageInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queryDict = ["query": "설현"]
        let headers = [
            "Authorization": "KakaoAK d3994f8190b66a9d3e493928bd27bd16",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Alamofire
            .request("https://dapi.kakao.com/v2/search/image",
                     method: .get,
                     parameters: queryDict,
                     headers: headers).responseObject
            { (res: DataResponse<APIImageResponse>) in
                switch (res.result) {
                case .success(let result):
                    self.imageInfoList = result.documents
                    self.tableView.reloadData()
                case .failure(let err):
                    debugPrint(err.localizedDescription)
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewController" {
            if let dest = segue.destination as? DetailViewController {
                guard let selectedIndex = tableView.indexPathForSelectedRow?.row else { return }
                
                dest.detailTitle = imageInfoList[selectedIndex].displaySitename
                dest.desc = imageInfoList[selectedIndex].docUrl
                dest.imageUrl = imageInfoList[selectedIndex].imageUrl
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageInfoListItem", for: indexPath)
        let nowIndex = indexPath.row
        
        guard let listItemCell = cell as? ImageInfoListItem else { return cell }
        
        listItemCell.labelTitle.text = imageInfoList[nowIndex].displaySitename
        listItemCell.labelDescription.text = imageInfoList[nowIndex].docUrl
        
        if let urlString = imageInfoList[nowIndex].thumbnailUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            if let url = URL(string: urlString) {
                listItemCell.thumbNailImageView.kf.setImage(with: url)
            }
        }
        
        return listItemCell
    }
}
