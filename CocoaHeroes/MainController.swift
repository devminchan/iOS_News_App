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
import RxSwift
import RxCocoa
import ReactorKit

class MainController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, StoryboardView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var imageInfoList: [ImageInfo] = []
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        tableView.dataSource = self
        tableView.delegate = self
        
        reactor?.action.onNext(.loadDefaultList)
    }
    
    private func setNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
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
        
        listItemCell.thumbNailImageView.layer.masksToBounds = true
        listItemCell.thumbNailImageView.layer.cornerRadius = 8.0
        
        if let urlString = imageInfoList[nowIndex].thumbnailUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            if let url = URL(string: urlString) {
                listItemCell.thumbNailImageView.kf.setImage(with: url)
            }
        }
        
        return listItemCell
    }
    
    func bind(reactor: MainReactor) {
        searchBar.rx.searchButtonClicked.map {
            let queryText = self.searchBar.text
            return MainReactor.Action.onSearch(queryText)
        }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.imageInfoList }
            .subscribe {
                guard let items = $0.element else { return }
                self.imageInfoList = items
                self.tableView.reloadData()
        }
        .disposed(by: disposeBag)
    }
}


