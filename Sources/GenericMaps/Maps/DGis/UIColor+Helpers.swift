//
//  UIColor+Helpers.swift
//  Maps
//
//  Created by Alexander Migachev on 19.05.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import UIKit

// MARK: Helpers
extension UIColor {

	/// Значение цвета в формате Int
	var hexa: Int {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return Int(alpha * 255) << 24
			 + Int(red * 255) << 16
			 + Int(green * 255) << 8
			 + Int(blue * 255)
	}
}
