//
//  Decimal+Extension.swift
//  impressions-ios
//
//  Created by 16695982 on 23.11.2021.
//

import Foundation

extension Decimal {
	var doubleValue:Double {
		return NSDecimalNumber(decimal:self).doubleValue
	}
}
