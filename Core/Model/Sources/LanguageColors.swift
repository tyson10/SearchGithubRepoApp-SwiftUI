//
//  LanguageColors.swift
//  Model
//
//  Created by Taeyoung Son on 2023/03/07.
//

import SwiftUI

import Extensions

public typealias LanguageColors = [String: LanguageColorValue]

public struct LanguageColorValue: Codable, Hashable {
    let hexColor: String?
    let url: String
    
    public var color: Color? {
        guard let hex = self.hexColor else { return nil }
        return .init(hex: hex)
    }
    
    enum CodingKeys: String, CodingKey {
        case hexColor = "color"
        case url
    }
}
