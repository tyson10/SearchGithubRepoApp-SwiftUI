//
//  SearchRepoOption.swift
//  Model
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

public struct SearchOption: Equatable {
    public var name: String
    public var sort: SortParam
    public var order: OrderParam
    public var page: Int
    
    public init(name: String, sort: SortParam = .default, order: OrderParam = .desc, page: Int = 1) {
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
    
    public mutating func nextPage() -> Self {
        self.page += 1
        return self
    }
    
    public mutating func set(order: OrderParam) -> Self {
        self.order = order
        return self
    }
    
    public mutating func set(sort: SortParam) -> Self {
        self.sort = sort
        return self
    }
}

public protocol QueryParamType: StringValue, CaseIterable, Identifiable, Titlable { }

public enum QueryParamMenu: Equatable {
    case order, sort
}

public enum SortParam: String, QueryParamType {
    case `default`
    case stars, forks
    case helpWantedIssue = "help-wanted-issues"
    case updated
    
    var paramValue: String? {
        if self == SortParam.`default` {
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

public enum OrderParam: String, QueryParamType {
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
