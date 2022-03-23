//
//  DGisMapStyleFactory.swift
//  impressions-ios
//
//  Created by Artem Zabludovsky on 20.08.2021.
//  Copyright © 2021 Heads and Hands. All rights reserved.
//

import UIKit
import DGis

/// Класс отвечающий за стиль карты 2ГИС
final class DGisMapStyleFactory {

	/// Получить первоначальные настройки карты со стилем
	/// - Parameters:
	///   - configuration: конфигурация
	///   - styleFactory: Интерфейс инструмента загрузки стилей
	/// - Returns: Первоначальные настройки карты
	func makeOptions(with configuration: GISConfigurationProtocol, styleFactory: IStyleFactory) -> MapOptions {
		var options = MapOptions.default
		let bundleName = configuration.styling.defaultNameResource
		let bundleType = configuration.styling.typeResource
		let fileName = "\(configuration.styling.fileName).\(configuration.styling.type)"

		if let path = Bundle.main.path(forResource: bundleName, ofType: bundleType) {
			options.styleFuture = styleFactory.loadFile(path: "\(path)/\(fileName)")
		}
		return options
	}
}
