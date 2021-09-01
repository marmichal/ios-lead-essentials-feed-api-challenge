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
					if let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [FeedImage] {
					} else {
						completion(.failure(RemoteFeedLoader.Error.invalidData))
					}
				}
			}
		}
	}
}
