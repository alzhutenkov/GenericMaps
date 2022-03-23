//
//  MapImageStateProvider.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

/// Интерфейс класса, предоставляющего MapImageState для объектов на карте
public protocol MapImageStateProviderProtocol {

	/// Запрос на MapImageState для определенного айтема
	/// - Parameters:
	///   - mapItem: Объект, для которого требуется MapImageState
	///   - currentZoom: Зум, для которого требуется MapImageState
	func image(for mapItem: MapItem, currentZoom: Int) -> MapImageState
}
