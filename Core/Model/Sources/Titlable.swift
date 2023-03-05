//
//  Titlable.swift
//  Model
//
//  Created by Taeyoung Son on 2023/03/04.
//

import Foundation

public protocol Titlable {
    static var title: String { get }
}

public extension Titlable {
    static var title: String {
        String(describing: Self.self)
    }
}
