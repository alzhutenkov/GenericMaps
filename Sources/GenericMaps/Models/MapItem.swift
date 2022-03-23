//
//  ClusterItem.swift
//  SberMaps
//
//  Created by Artem Zabludovsky on 15.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import UIKit

/// MapItemImage
public struct MapItemImage {
	public var selectedImage: UIImage?
	public var unselectedImage: UIImage?
}

/// Элемент, который отображается на карте
public struct MapItem {

	/// Координата
	public var coordinate: MapCoordinate

	/// Переменная для общего использования
	public var object: Any?

	/// image
	public var image: MapItemImage?

	/// Флаг отображения на заднем фоне
	public var toBackground = false

	/// хэш связанного объекта карт
	public var hashMapObject = 0

	/// Может ли пин быть выбран
	public var canBeSelected = true

	/// Иницилизация
	///
	/// - Parameter coordinate: Координата
	public init(coordinate: MapCoordinate) {
		self.coordinate = coordinate
	}
}

// MARK: - Hashable

extension MapItem: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(coordinate)
	}
}

// MARK: - Equatable

public extension MapItem: Equatable {
	public static func == (lhs: MapItem, rhs: MapItem) -> Bool {
		return lhs.coordinate == rhs.coordinate
	}
}
