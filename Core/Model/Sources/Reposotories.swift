//
//  Reposotories.swift
//  Model
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

// MARK: - Repositories
public struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// MARK: - Item
public struct Repository: Codable {
    let name: String
    let owner: RepositoryOwner
    let language, description: String?
    let stargazersCount: Int

    enum CodingKeys: String, CodingKey {
        case name, owner, language, description
        case stargazersCount = "stargazers_count"
    }
}

// MARK: - Owner
public struct RepositoryOwner: Codable {
    let login: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}
