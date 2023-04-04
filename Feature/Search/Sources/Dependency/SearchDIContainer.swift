//
//  SearchDIContainer.swift
//  Search
//
//  Created by Taeyoung Son on 2023/04/03.
//

import SwiftUI

import CommonUI

public final class SearchDIContainer {
    public init() { }
    
    public func makeSearchView<ResultView: SearchResultView>(resultViewMaker: ((String) -> ResultView)?) -> SearchView<ResultView> {
        return .init(resultViewMaker: resultViewMaker)
    }
}
