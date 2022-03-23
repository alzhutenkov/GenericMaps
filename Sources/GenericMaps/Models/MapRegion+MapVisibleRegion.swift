//
//  MapRegion+MapVisibleRegion.swift
//  Maps
//
//  Created by Artem Zabludovsky on 15.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

public extension MapRegion {

	/// Иницилизация
	///
	/// - Parameter mapVisibleRegion: Модель описывающая видимую часть карты
	public init(mapVisibleRegion: MapVisibleRegion) {
		let region = mapVisibleRegion
		let latitudes = [region.topLeft.latitude,
						 region.topRight.latitude,
						 region.bottomLeft.latitude,
						 region.bottomRight.latitude]
		let sortedLatitudes = latitudes.sorted()
		let minLat = sortedLatitudes.first ?? region.topLeft.latitude
		let maxLat = sortedLatitudes.last ?? region.topLeft.latitude
		
		let longitudes = [region.topLeft.longitude,
						  region.topRight.longitude,
						  region.bottomLeft.longitude,
						  region.bottomRight.longitude]
		let sortedLongitudes = longitudes.sorted()
		let minLong = sortedLongitudes.first ?? region.topLeft.longitude
		let maxLong = sortedLongitudes.last ?? region.topLeft.longitude
		
		span = MapRegionSize(latitudeDelta: maxLat - minLat,
							 longitudeDelta: maxLong - minLong)
		
		center = MapCoordinate(latitude: (maxLat + minLat) / 2,
							   longitude: (maxLong + minLong) / 2)
	}
}
