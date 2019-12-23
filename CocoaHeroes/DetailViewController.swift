//
//  DetailViewController.swift
//  CocoaHeroes
//
//  Created by 김민찬 on 2019/12/23.
//  Copyright © 2019 김민찬. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var imageUrl: String?
    var detailTitle: String?
    var desc: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTitleLabel.text = detailTitle
        detailDescriptionLabel.text = desc
        
        guard let urlString = imageUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: urlString) else { return }
        
        detailImageView.kf.setImage(with: url)
    }
}
