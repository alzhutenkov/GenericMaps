//
//  MapPolyline.swift
//  Maps
//
//  Created by Artem Zabludovsky on 09.08.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import UIKit

/// Полилиния, которая отображается на карте
public class MapPolyline: Hashable {

	/// Координаты
	public var coordinates: [MapCoordinate]

	/// Переменная для общего использования
	public var userData: Any

	/// Цвет
	public var color: UIColor

	/// Индекс положения по Z вертикали
	public var zIndex: Int = 0

	/// Флаг отображения на заднем фоне
	public var width: CGFloat = 8

	/// Иницилизация
	///
	/// - Parameters
	/// 	- coordinate: Координата
	/// 	- color: Цвет
	/// 	- userData: Переменная для общего использования
	public init(coordinates: [MapCoordinate], color: UIColor, userData: Any) {
		self.coordinates = coordinates
		self.color = color
		self.userData = userData
	}

	public static func == (lhs: MapPolyline, rhs: MapPolyline) -> Bool {
		lhs.coordinates == rhs.coordinates
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(coordinates)
		hasher.combine(color)
		hasher.combine(zIndex)
		hasher.combine(width)
	}
}
