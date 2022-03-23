//
//  MapAnnotation.swift
//  Maps
//
//  Created by Artem Zabludovsky on 08.08.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import Foundation
import UIKit

/// Элемент, который отображается на карте
public struct MapAnnotation {

	/// Координата
	public var coordinate: MapCoordinate

	/// Переменная для общего использования
	public var object: Any?

	/// Картинка
	public var image: UIImage

	/// Индекс положения по Z вертикали
	public var zIndex: Int = 0

	/// Иницилизация
	///
	/// - Parameters:
	/// 	- coordinate: Координата
	/// 	- image: Картинка
	public init(coordinate: MapCoordinate, image: UIImage) {
		self.coordinate = coordinate
		self.image = image
	}
}
