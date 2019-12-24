//
//  MainReactor.swift
//  CocoaHeroes
//
//  Created by 김민찬 on 2019/12/23.
//  Copyright © 2019 김민찬. All rights reserved.
//

import ReactorKit
import RxSwift
import Alamofire
import ObjectMapper

class MainReactor: Reactor {
    
    enum Action {
        case loadSearchResult
        case goToDetail(Int)
    }
    
    enum Mutation {
        case searchImageInfoList([ImageInfo])
        case detail(Int)
    }
    
    struct State {
        var imageInfoList: [ImageInfo] = []
        var detailIndex: Int = 0
    }
    
    var initialState = State()
    
    func mutate(action: MainReactor.Action) -> Observable<MainReactor.Mutation> {
        switch action {
        case .loadSearchResult:
            return getImageInfoList(query: "설현").flatMap { list -> Observable<MainReactor.Mutation> in
                return Observable.just(.searchImageInfoList(list))
            }
        case .goToDetail(let idx):
            return Observable.just(.detail(idx))
        }
    }
    
    func reduce(state: MainReactor.State, mutation: MainReactor.Mutation) -> MainReactor.State {
        var newState = state
        
        switch mutation {
        case .searchImageInfoList(let imageInfoList):
            newState.imageInfoList = imageInfoList
        case .detail(let idx):
            newState.detailIndex = idx
        }
        
        return newState
    }
    
    private func getImageInfoList(query: String) -> Observable<[ImageInfo]> {
        let queryDict = ["query": "설현"]
        let headers = [
            "Authorization": "KakaoAK d3994f8190b66a9d3e493928bd27bd16",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        return Observable.create { observer -> Disposable in
            let dataRequest = Alamofire.request("https://dapi.kakao.com/v2/search/image",
                         method: .get,
                         parameters: queryDict,
                         headers: headers).responseObject
                { (res: DataResponse<APIImageResponse>) in
                    switch (res.result) {
                    case .success(let result):
                        observer.onNext(result.documents)
                        observer.onCompleted()
                    case .failure(let err):
                        debugPrint(err.localizedDescription)
                        observer.onError(err)
                        observer.onCompleted()
                    }
            }
            
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }
}
