//
//  GeoRectExtension.swift
//  Maps
//
//  Created by Artem Kislitsyn on 07.05.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import Foundation
import DGis

extension DGis.GeoRect {

	/// Расширение прямоугольника
	///
	/// - Parameter ratio: Соотношение
	/// - Returns: Увеличенный прямоугольник
	func expanded(by ratio: Double) -> GeoRect {
		let width = northEastPoint.longitude.value - southWestPoint.longitude.value
		let widthExpansion = width * (ratio - 1)
		let height = northEastPoint.latitude.value - southWestPoint.latitude.value
		let heightExpansion = height * (ratio - 1)

		let longitudeEast = northEastPoint.latitude.value + heightExpansion
		let longitudeWest = southWestPoint.longitude.value - widthExpansion
		let latitudeSouth = southWestPoint.latitude.value - heightExpansion
		let latitudeNorth = northEastPoint.latitude.value + heightExpansion

		let southWestPoint = GeoPoint(latitude: latitudeSouth,
									  longitude: longitudeWest)
		let northEastPoint = GeoPoint(latitude: latitudeNorth,
									  longitude: longitudeEast)
		return GeoRect(southWestPoint: southWestPoint, northEastPoint: northEastPoint)
	}
}
