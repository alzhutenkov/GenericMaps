//
//  MapRegion.swift
//  SberMaps
//
//  Created by Artem Zabludovsky on 15.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import Foundation

/// Регион на карте
public struct MapRegion {

	/// Координата центра региона
	public let center: MapCoordinate

	/// Размер региона
	public let span: MapRegionSize

	/// Иницилизация
	///
	/// - Parameters:
	///   - center: Координата центра региона
	///   - span: Размер региона
	public init(center: MapCoordinate, span: MapRegionSize) {
		self.center = center
		self.span = span
	}
}

public extension MapRegion {

	/// Зум региона
	/// 
	/// - Returns: зум
	func zoomLevel() -> Int {
		guard span.longitudeDelta > 0 else { return 15 }
		return Int(log2(360 / span.longitudeDelta)) + 1
	}

	/// Преобразование в прямоугольник карты
	var mapRect: MapRect {
		return MapRect(topLeft: MapCoordinate(latitude: center.latitude + span.latitudeDelta / 2,
										   longitude: center.longitude - span.longitudeDelta / 2),
					   bottomRight: MapCoordinate(latitude: center.latitude - span.latitudeDelta / 2,
											   longitude: center.longitude + span.longitudeDelta / 2))
	}
}
