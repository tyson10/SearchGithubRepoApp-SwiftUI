//
//  Reposotories.swift
//  Model
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

// MARK: - Repositories
public struct Repositories: Codable, Equatable {
    public var totalCount: Int
    public var incompleteResults: Bool
    public var items: [Repository]

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
    
    public mutating func merge(langColors: LanguageColors) {
        let colors = self.items.map { langColors[$0.language ?? ""] }
        
        colors.enumerated().forEach { offset, color in
            self.items[offset].langColor = color
        }
    }
}

// MARK: - Item
public struct Repository: Codable, Hashable {
    public let name: String
    public let owner: RepositoryOwner
    public let language, description: String?
    public let stargazersCount: Int
    public var langColor: LanguageColorValue?

    public enum CodingKeys: String, CodingKey {
        case name, owner, language, description, langColor
        case stargazersCount = "stargazers_count"
    }
}

// MARK: - Owner
public struct RepositoryOwner: Codable, Hashable {
    public let login: String
    public let avatarURL: String

    public enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}
