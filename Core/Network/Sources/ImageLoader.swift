//
//  ImageLoader.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import SwiftUI
import Combine

public class ImageLoader: ObservableObject {
    @Published public var image: UIImage?

    private var network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    public init(network: NetworkService = NetworkService(session: URLSession.shared)) {
        self.network = network
    }

    public func fetch(urlString: String?) {
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
