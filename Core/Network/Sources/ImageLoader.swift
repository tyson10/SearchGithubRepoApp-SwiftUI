//
//  ImageLoader.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import SwiftUI
import Combine

import Model

public class ImageLoader: ObservableObject {
    @Published public var image: UIImage?
    
    private var network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    public init(network: NetworkService = NetworkService(session: URLSession.shared)) {
        self.network = network
    }
    
    public func fetch(urlString: String?) {
        guard let urlString = urlString else { return }
        
        if let image = ImageCache.shared.get(forKey: urlString) {
            self.image = image
            return
        }
        
        network.request(endPoint: .image(url: urlString))
            .sink { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { data in
                /// sync 콘텍스트에서 GCD 사용을 위해 Task로 감싼다.
                Task {
                    guard let image = await data.thumbnailImage else { return }
                    
                    /// UI 관련 변수를 업데이트 할 때, 메인스레드에서 동작해야 함.
                    /// 별도의 조치 없이 async 콘텍스트에서 업데이트시에 'Publishing changes from background threads is not allowed task' 워닝 발생
                    /// MainActor 사용
                    await MainActor.run { [weak self] in
                        self?.image = image
                    }
                    
                    // 사실상 URLCache 적용으로 불필요함.
                    ImageCache.shared.set(forKey: urlString, image: image)
                    
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

private extension Data {
    func toThumbnailImage(of size: CGSize) async -> UIImage? {
        return await UIImage(data: self)?.byPreparingThumbnail(ofSize: size)
    }
    
    // Property에도 get 메소드에 async 붙여서 사용 가능.
    var thumbnailImage: UIImage? {
        get async {
            return await UIImage(data: self)?.byPreparingThumbnail(ofSize: .init(width: 40, height: 40))
        }
    }
}
