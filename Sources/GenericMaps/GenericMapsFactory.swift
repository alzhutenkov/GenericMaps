//
//  GenericMaps.swift
//  
//
//  Created by Alexey Zhutenkov on 14.03.2022.
//

import UIKit

#if DGISMAPS
import DGis
#endif

public enum GenericMapsType: String, CaseIterable {
#if DGISMAPS
	case dGIS
#endif
#if APPLEMAPS
	case appleMaps
#endif
}

public class GenericMapsFactory {
	static public func map(by type: GenericMapsType) -> FacadeMapProtocol {
		switch type {
#if DGISMAPS
		case .dGIS:
			return GISMapView(sdk: DGisContainer.shared.sdk)
#endif
#if APPLEMAPS
		case .appleMaps:
			return AMapView()
#endif
		}
	}

	/// Получение инстанса типа карты в зависимости от конфига
	static public var map: FacadeMapProtocol {
		guard let type = GenericMapsType.allCases.first else {
			fatalError("Something wrong with maps")
		}
		return map(by: type)
	}
}
