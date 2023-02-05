//
//  NetworkError.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import Foundation

public enum NetworkError: Error {
    case invalidRequest
    case unknown(error: Error)
}
