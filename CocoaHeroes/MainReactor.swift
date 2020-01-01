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
    
    enum MainError: Error {
        case emptyQuery
    }
    
    enum Action {
        case loadDefaultList
        case onSearch(String?)
        case goToDetail(Int)
    }
    
    enum Mutation {
        case setImageInfoList([ImageInfo])
        case detail(Int)
        case onError(Error)
    }
    
    struct RevisionedError: Equatable {
        fileprivate let revision: UInt
        let error: Error
        
        init(revision: UInt, error: Error) {
            self.revision = revision
            self.error = error
        }
        
        static func == (lhs: MainReactor.RevisionedError, rhs: MainReactor.RevisionedError) -> Bool {
            return lhs.revision == rhs.revision
        }
    }
    
    struct State {
        var imageInfoList: [ImageInfo] = []
        var detailIndex: Int = 0
        var error: RevisionedError?
    }
    
    var initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadDefaultList:
            return getImageInfoList(query: "설현")
                .map(Mutation.setImageInfoList)
                .catchError { error -> Observable<Mutation> in .just(.onError(error)) }
        case .onSearch(let queryText):
            return Observable.just(queryText).map { query in
                guard let result = query else { throw MainError.emptyQuery }
                if result.isEmpty { throw MainError.emptyQuery }
                return result
            }
            .flatMap { query -> Observable<[ImageInfo]> in self.getImageInfoList(query: query) }
            .map(Mutation.setImageInfoList)
            .catchError { error -> Observable<Mutation> in .just(.onError(error)) }
        case .goToDetail(let idx):
            return .just(.detail(idx))
        }
    }
    
    func reduce(state: MainReactor.State, mutation: MainReactor.Mutation) -> MainReactor.State {
        var newState = state
        
        switch mutation {
        case .setImageInfoList(let imageInfoList):
            newState.imageInfoList = imageInfoList
        case .detail(let idx):
            newState.detailIndex = idx
        case .onError(let error):
            if let prevError = state.error {
                newState.error = RevisionedError(revision: prevError.revision + 1, error: error)
            } else {
                newState.error = RevisionedError(revision: 0, error: error)
            }
        }
        
        return newState
    }
    
    private func getImageInfoList(query: String) -> Observable<[ImageInfo]> {
        let queryDict = ["query": query]
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
