//
//  MapVector.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

/// Модель вектора на карте
public struct MapVector {

	/// Точка начала вектора
	public let start: MapCoordinate

	/// Точка окончания вектора
	public let finish: MapCoordinate

	/// Иницилизация
	/// - Parameters:
	///   - start: Точка начала вектора
	///   - finish: Точка окончания вектора
	public init(start: MapCoordinate, finish: MapCoordinate) {
		self.start = start
		self.finish = finish
	}
}

public extension MapVector {
	/// Определение положения точки, относителя текущего вектора
	/// - Parameter point: Точка для определения
	/// - Returns: Ответ на вопрос: лежит ли точка справа от вектора или нет
	public func pointBelongToRightSideOfVector(_ point: MapCoordinate) -> Bool {
		let coefficientD = (finish.latitude - start.latitude) * (point.longitude - start.longitude) -
		(point.latitude - start.latitude) * (finish.longitude - start.longitude)
		return coefficientD >= 0
	}
}
