//
//  ImageLoader.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import SwiftUI
import Combine

class URLImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let network = NetworkService(session: URLSession.shared)
    private var cancellables = Set<AnyCancellable>()

    func fetch(urlString: String?) {
        guard let urlString = urlString else { return }
        
        network.request(endPoint: .image(url: urlString))
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("success")
                }
            } receiveValue: { [weak self] data in
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
