//
//  DGisContainer.swift
//  impressions-ios
//
//  Created by Artem Zabludovsky on 20.08.2021.
//  Copyright © 2021 Heads and Hands. All rights reserved.
//

import Foundation
import DGis

/// Контейнер с sdk 2ГИС
final class DGisContainer {

	/// SDK 2гис
	lazy var sdk = DGis.Container(apiKeys: apiKeys, httpOptions: HTTPOptions(timeout: 5, cacheOptions: nil))

	static var shared = DGisContainer()
	private init() {}

	/// Ключи
	private lazy var apiKeys: APIKeys = {
		guard let apiKeys = APIKeys(directory: "ruoipx9146", map: "af43c7f0-3254-4383-a209-ca9f3cf63693")
		else { fatalError("2GIS API keys are invalid.") }
		return apiKeys
	}()
}
