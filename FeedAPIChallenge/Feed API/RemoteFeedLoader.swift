//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private enum Constants {
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
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, httpResponse)):
				guard httpResponse.statusCode == Constants.successSatusCode,
				      let images = try? JSONDecoder().decode(FeedLoaderResponse.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}

				completion(.success(images.items.feedImageItems()))
			}
		}
	}
}

private struct FeedLoaderResponse: Decodable {
	let items: [Image]
}

private struct Image: Decodable {
	public let image_id: UUID
	public let image_desc: String?
	public let image_loc: String?
	public let image_url: URL

	var feedImage: FeedImage {
		return FeedImage(
			id: image_id,
			description: image_desc,
			location: image_loc,
			url: image_url
		)
	}
}

extension Array where Element == Image {
	func feedImageItems() -> [FeedImage] {
		return map { $0.feedImage }
	}
}
