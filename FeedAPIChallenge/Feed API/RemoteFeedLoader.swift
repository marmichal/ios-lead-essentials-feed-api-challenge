//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	enum Constants {
		static let successSatusCode = 200
	}

	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure(_):
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			case .success((let data, let httpResponse)):
				if httpResponse.statusCode != Constants.successSatusCode {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				} else {
					if let images = try? JSONDecoder().decode(FeedLoaderResponse.self, from: data) {
						completion(.success(images.items.compactMap { $0.feedImage }))
					} else {
						completion(.failure(RemoteFeedLoader.Error.invalidData))
					}
				}
			}
		}
	}
}

struct FeedLoaderResponse: Decodable {
	let items: [Image]
}

struct Image: Decodable {
	public let image_id: UUID
	public let image_desc: String?
	public let image_loc: String?
	public let image_url: String

	var feedImage: FeedImage? {
		if let url = URL(string: image_url) {
			return FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: url
			)
		}
		return nil
	}
}
