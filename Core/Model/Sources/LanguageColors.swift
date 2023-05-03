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
    
    var color: Color? {
        guard let hex = self.hexColor else { return nil }
        return .init(hex: hex)
    }
    
    enum CodingKeys: String, CodingKey {
        case hexColor = "color"
        case url
    }
}

public final class LangColorPalette {
    public static var shared = LangColorPalette()
    private var colors = LanguageColors()
    
    public func set(colors: LanguageColors) {
        self.colors = colors
    }
    
    public func color(language: String?) -> Color? {
        guard let lang = language else { return nil }
        return self.colors[lang]?.color
    }
}
