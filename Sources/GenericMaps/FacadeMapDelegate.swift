//
//  FacadeMapDelegate.swift
//  Maps
//
//  Created by Artem Zabludovsky on 13.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

/// Делегат фасада карты
public protocol FacadeMapDelegate: AnyObject {

	/// Уведомление о выделении элемента на карте
	///
	/// - Parameters:
	///   - mapView: Карта
	///   - item: Выбранный элемент
	func mapView(_ mapView: FacadeMapProtocol, didSelect item: MapItem)

	/// Уведомление о смене региона карты и видимой части
	/// - Parameters:
	///   - mapView: Карта
	///   - mapRegion: Регион, который представляет собой описанный прямоугольник вокруг видимого региона
	///   - visibleRegion: Видимий прямоугольник карты
	func mapView(_ mapView: FacadeMapProtocol, didChange mapRegion: MapRegion, visibleRegion: MapVisibleRegion)

	/// Уведомление о нажатии на полилинию
	/// - Parameters:
	///   - mapView: Карта
	///   - polyline: Полилиния, которая была нажата
	func mapView(_ mapView: FacadeMapProtocol, didSelect polyline: MapPolyline)

	/// Уведомление о нажатии на аннотацию
	/// - Parameters:
	///   - mapView: Карта
	///   - annotation: Аннотация, которая была нажата
	func mapView(_ mapView: FacadeMapProtocol, didSelect annotation: MapAnnotation)
}

extension FacadeMapDelegate {
	public func mapView(_ mapView: FacadeMapProtocol, didSelect polyline: MapPolyline) {}
	public func mapView(_ mapView: FacadeMapProtocol, didSelect annotation: MapAnnotation) {}
}

/// Делегат фасада карты
protocol FacadeClusterMapDelegate: AnyObject {

	/// Выбор нажатого кластера
	/// Уведомление о смене региона карты и видимой части
	/// - Parameters:
	///   - mapView: Карта
	///   - mapRegion: Регион, который представляет собой описанный прямоугольник вокруг видимого региона
	///   - visibleRegion: Видимий прямоугольник карты
	//    - indivisibility: видимость
	func mapView(_ mapView: FacadeMapProtocol,
				 didSelectCluster annotations: [MapItem],
				 visibleRegion: MapVisibleRegion, indivisibility: Bool)
}
