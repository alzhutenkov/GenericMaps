//
//  MapVisibleRegion.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import Foundation

/// Модель полностью описывающая текущий регион отображаемый на карте
public struct MapVisibleRegion {

	/// Верхний правый угол
	public let topRight: MapCoordinate

	/// Верхний левый угол
	public let topLeft: MapCoordinate

	/// Нижний правый угол
	public let bottomRight: MapCoordinate

	/// Нижний левый угол
	public let bottomLeft: MapCoordinate

	/// Иницилизация
	/// 
	/// - Parameters:
	///   - topRight: Верхний правый угол
	///   - topLeft: Верхний левый угол
	///   - bottomRight: Нижний правый угол
	///   - bottomLeft: Нижний левый угол
	public init(topRight: MapCoordinate, topLeft: MapCoordinate, bottomRight: MapCoordinate, bottomLeft: MapCoordinate) {
		self.topRight = topRight
		self.topLeft = topLeft
		self.bottomRight = bottomRight
		self.bottomLeft = bottomLeft
	}

	/// Центр видимого региона
	public var center: MapCoordinate {
		MapCoordinate(latitude: (topRight.latitude + bottomLeft.latitude) / 2,
				   longitude: (topRight.longitude + bottomLeft.longitude) / 2)
	}

	/// Зум видимого региона
	public var zoom: Int {
		let longitudeDelta = sqrt(pow((topLeft.longitude - bottomLeft.longitude), 2)
									+ pow(topLeft.latitude - bottomLeft.latitude, 2))
		guard longitudeDelta > 0 else { return 15 }
		return Int(log2(360 / longitudeDelta)) + 1
	}
}

public extension MapVisibleRegion {
	public func pointBelongsToRegion(_ point: MapCoordinate) -> Bool {
		let vectors = [MapVector(start: bottomLeft, finish: topLeft),
					   MapVector(start: topLeft, finish: topRight),
					   MapVector(start: topRight, finish: bottomRight),
					   MapVector(start: bottomRight, finish: bottomLeft)]
		
		for vector in vectors {
			let onRightSideOfVector = vector.pointBelongToRightSideOfVector(point)
			if !onRightSideOfVector {
				return false
			}
		}
		return true
	}
}
