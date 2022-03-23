//
//  MapImageState.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import UIKit

/// Модель, определяющая отображение пина
public struct MapImageState {
	public typealias ImageRetriverBlock = () -> UIImage?

	/// Блок, определяющий картинку в невыбранном состояниии
	public let unselectedImageRetriver: ImageRetriverBlock

	/// Блок, определяющий картинку в выбранном состояниии
	public var selectedImageRetriver: ImageRetriverBlock?

	/// Блок, определяющий картинку в  состояниии отображения на заднем фоне
	public var backgroundImageRetriver: ImageRetriverBlock?

	/// Отображение пина в невыбранном состояниии
	public var unselectedImage: UIImage { unselectedImageRetriver() ?? UIImage() }

	/// Отображение пина в выбранном состояниии
	public var selectedImage: UIImage { selectedImageRetriver?() ?? UIImage() }

	/// Отображение пина в  состояниии отображения на заднем фоне
	public var backgroundImage: UIImage { backgroundImageRetriver?() ?? UIImage() }

	/// Иницилизация
	///
	/// - Parameters:
	///   - unselectedImageRetriver: Блок, определяющий картинку в невыбранном состояниии
	///   - selectedImageRetriver: Блок, определяющий картинку в выбранном состояниии
	///   - backgroundImageRetriver: Блок, определяющий картинку в  состояниии отображения на заднем фоне
	public init(unselectedImageRetriver: @escaping ImageRetriverBlock,
				selectedImageRetriver: ImageRetriverBlock?,
				backgroundImageRetriver: ImageRetriverBlock?) {
		self.unselectedImageRetriver = unselectedImageRetriver
		self.selectedImageRetriver = selectedImageRetriver
		self.backgroundImageRetriver = backgroundImageRetriver
	}
}
