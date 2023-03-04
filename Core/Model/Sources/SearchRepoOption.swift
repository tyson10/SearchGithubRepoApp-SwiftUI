//
//  SearchRepoOption.swift
//  Model
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

public struct SearchRepoOption: Equatable {
    var name: String
    var sort: RepoSortType
    var order: RepoOrderType
    var page: Int
    
    public init(name: String, sort: RepoSortType = .default, order: RepoOrderType = .desc, page: Int = 1) {
        self.name = name
        self.sort = sort
        self.order = order
        self.page = page
    }
    
    public func toParameters() -> Parameters {
        var params = Parameters()
        params["q"] = self.name
        params["per_page"] = 10
        params["page"] = self.page
        params["sort"] = self.sort.paramValue
        params["order"] = self.order.rawValue
        return params
    }
}

public protocol SearchOptionType: StringValue, CaseIterable, Identifiable, Titlable { }

public enum RepoSortType: String, SearchOptionType {
    case `default`
    case stars, forks
    case helpWantedIssue = "help-wanted-issues"
    case updated
    
    var paramValue: String? {
        if self == RepoSortType.`default` {
            return nil
        } else {
            return self.rawValue
        }
    }
    
    public var stringValue: String {
        self.rawValue
    }
    
    public var id: String {
        self.rawValue
    }
    
    public static var title: String {
        "Sort"
    }
}

public enum RepoOrderType: String, SearchOptionType {
    case desc, asc
    
    public var stringValue: String {
        self.rawValue
    }
    
    public var id: String {
        self.rawValue
    }
    
    public static var title: String {
        "Order"
    }
}
