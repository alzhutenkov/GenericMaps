//
//  MapRegionSize.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

public typealias CoordinateDegrees = Double

/// Размер региона в градусах
public struct MapRegionSize {

	/// Вертикальное расстояние
	public let latitudeDelta: CoordinateDegrees

	/// Горизонтальное расстояние
	public let longitudeDelta: CoordinateDegrees

	/// Иницилизация
	///
	/// - Parameters:
	///   - latitudeDelta: Вертикальное расстояние
	///   - longitudeDelta: Горизонтальное расстояние
	public init(latitudeDelta: Double, longitudeDelta: Double) {
		self.latitudeDelta = latitudeDelta
		self.longitudeDelta = longitudeDelta
	}
}
