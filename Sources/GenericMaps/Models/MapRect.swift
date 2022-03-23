//
//  MapRect.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

/// Прямоугольная область на карте
public struct MapRect {

	/// Координата левого верхнего угла области
	public let topLeft: MapCoordinate

	/// Координата правого нижнего угла области
	public let bottomRight: MapCoordinate

	/// Иницилизация
	/// - Parameters:
	///   - topLeft: Координата левого верхнего угла области
	///   - bottomRight: Координата правого нижнего угла области
	public init(topLeft: MapCoordinate, bottomRight: MapCoordinate) {
		self.topLeft = topLeft
		self.bottomRight = bottomRight
	}

	/// Преобразование к региону карты
	var mapRegion: MapRegion {
		return MapRegion(center: MapCoordinate(latitude: (topLeft.latitude + bottomRight.latitude) / 2,
											longitude: (bottomRight.longitude + topLeft.longitude) / 2),
						 span: MapRegionSize(latitudeDelta: topLeft.latitude - bottomRight.latitude,
											 longitudeDelta: bottomRight.longitude - topLeft.longitude))
	}
}
