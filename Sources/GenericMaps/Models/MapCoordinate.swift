//
//  MapCoorditane.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import Foundation

/// Модель координаты
public struct MapCoordinate: Codable, Equatable, Hashable {

	/// Широта
	public var latitude: Double

	/// Долгота
	public var longitude: Double

	/// Иницилизация
	/// 
	/// - Parameters:
	///   - latitude: Широта
	///   - longitude: Долгота
	public init(latitude: Double, longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
}

public extension MapCoordinate {
	/// Нулевая координата
	public static let zero = MapCoordinate(latitude: 0.0, longitude: 0.0)

	public func approximateDelta(approximateDelta: Double) -> MapCoordinate {
		let koef = 1 / cos(self.latitude / 180 * Double.pi)
		let centerX = floor((180 + self.longitude) / approximateDelta)
		let centerY = floor(self.latitude * koef / approximateDelta)
		return MapCoordinate(latitude: centerY, longitude: centerX)
	}
}
