//
//  SearchDIContainer.swift
//  Search
//
//  Created by Taeyoung Son on 2023/04/03.
//

import SwiftUI

import CommonUI


public final class SearchDIContainer<ResultView: SearchResultView> {
    private let resultViewMaker: ((String) -> ResultView)?
    
    public init(resultViewMaker: ((String) -> ResultView)?) {
        self.resultViewMaker = resultViewMaker
    }
    
    public func makeSearchView(with query: String) -> SearchView<ResultView> {
        return .init(resultViewMaker: resultViewMaker)
    }
}
