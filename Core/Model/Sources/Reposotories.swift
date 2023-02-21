//
//  Reposotories.swift
//  Model
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

// MARK: - Repositories
public struct Repositories: Codable {
    public var totalCount: Int
    public var incompleteResults: Bool
    public var items: [Repository]

    public enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// MARK: - Item
public struct Repository: Codable, Hashable {
    public let name: String
    public let owner: RepositoryOwner
    public let language, description: String?
    public let stargazersCount: Int

    public enum CodingKeys: String, CodingKey {
        case name, owner, language, description
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
