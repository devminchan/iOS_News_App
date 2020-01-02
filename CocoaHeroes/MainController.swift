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
import SideMenu

class MainController: UIViewController, StoryboardView {
    
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: nil, action: nil)
    
    var disposeBag = DisposeBag()
    var itemCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        setLocalUIEventListeners()
        
        reactor?.action.onNext(.loadDefaultList)
    }
    
    private func setNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.leftBarButtonItem = menuButton
    }
    
    func bind(reactor: MainReactor) {
        searchController.searchBar.rx.searchButtonClicked.map {
            let queryText = self.searchController.searchBar.text
            return MainReactor.Action.onSearch(queryText)
        }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.imageInfoList }
            .bind(to: tableView.rx.items(cellIdentifier: "ImageInfoListItem")) {
                (index: Int, element: ImageInfo, cell: ImageInfoListItem) in
                cell.labelTitle.text = element.displaySitename
                cell.labelDescription.text = element.docUrl
                
                cell.thumbNailImageView.contentMode = .scaleAspectFill
                cell.thumbNailImageView.layer.cornerRadius = 8.0
                cell.thumbNailImageView.layer.masksToBounds = true
                
                if let imageUrl = element.imageUrl {
                    cell.thumbNailImageView.kf.setImage(with: URL(string: imageUrl))
                }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ImageInfo.self)
            .bind { imageInfo in
                let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                detailViewController.imageUrl = imageInfo.imageUrl
                detailViewController.detailTitle = imageInfo.displaySitename
                detailViewController.desc = imageInfo.docUrl
                
                self.navigationController?.pushViewController(detailViewController, animated: true)
        }
        .disposed(by: disposeBag)
    }
    
    func setLocalUIEventListeners() {
        menuButton.rx.tap.throttle(.milliseconds(300), scheduler: MainScheduler.instance).bind { _ in
            self.present(self.sideMenu, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
}

extension UIViewController {
    var sideMenu: SideMenuNavigationController {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        let sideMenu = SideMenuNavigationController(rootViewController: menuViewController)
        sideMenu.leftSide = true
        sideMenu.settings = getSideMenuSetting()
        
        return sideMenu
    }
    
    private func getSideMenuSetting() -> SideMenuSettings {
        let displayOptions: SideMenuPresentationStyle = .menuSlideIn
        displayOptions.backgroundColor = .black
        displayOptions.presentingEndAlpha = CGFloat(0.5)
        
        var setting = SideMenuSettings()
        setting.presentationStyle = displayOptions
        setting.statusBarEndAlpha = 0
        
        return setting
    }
}
