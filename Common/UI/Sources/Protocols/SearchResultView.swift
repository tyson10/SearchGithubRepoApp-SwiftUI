//
//  SearchingViewType.swift
//  CommonUI
//
//  Created by Taeyoung Son on 2023/03/19.
//

import SwiftUI

public protocol SearchResultView: View {
    associatedtype T
    init(networkService: T, searchWord: String)
}
