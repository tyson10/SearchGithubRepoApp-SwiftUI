//
//  URLImage.swift
//  CommonUI
//
//  Created by Taeyoung Son on 2023/02/13.
//

import SwiftUI

import Network

public struct URLImage: View {
    
    @StateObject private var imageLoader = ImageLoader()
    
    private var urlStr: String?
    
    public init(url: String?) {
        self.urlStr = url
    }
    
    public var body: some View {
        content
            .onAppear {
                imageLoader.fetch(urlString: urlStr)
            }
    }
    
    private var content: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(url: "https://www.google.co.kr/url?sa=i&url=https%3A%2F%2Fturtle301.tistory.com%2Fentry%2F%25EB%25B9%2585%25ED%2586%25A0%25EB%25A6%25AC%25EC%2595%2584-%25ED%258E%2598%25EB%2593%259C%25EB%25A0%2588%25ED%258B%25B0-Victoria-Pedretti-%25EB%2584%25B7%25ED%2594%258C%25EB%25A6%25AD%25EC%258A%25A4-%25EB%2584%2588%25EC%259D%2598-%25EB%25AA%25A8%25EB%2593%25A0-%25EA%25B2%2583-%25EC%258B%259C%25EC%25A6%258C2-%25EB%259F%25AC%25EB%25B8%258C-%25ED%2580%25B8-%25EC%259E%2591%25EC%25A0%2595%25ED%2595%2598%25EA%25B3%25A0-%25EC%2593%25B0%25EB%258A%2594-%25EB%258D%2595%25EC%25A7%2588-%25EA%25B8%25B0%25EB%25A1%259D&psig=AOvVaw2KpussrQBLq09uh8gHpGut&ust=1676382302954000&source=images&cd=vfe&ved=0CA8QjRxqFwoTCKCZ6e7Qkv0CFQAAAAAdAAAAABAE")
    }
}
