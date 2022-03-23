//
//  FacadeMapViewProtocol.swift
//  Maps
//
//  Created by Artem Zabludovsky on 15.03.2021.
//  Copyright © 2021 Sberbank. All rights reserved.
//

import UIKit

/// Интерфейс фасада карты
public protocol FacadeMapProtocol: AnyObject {

	/// Вью, отображающая карту
	var mapView: UIView { get }

	/// Делегат карты
	var delegate: FacadeMapDelegate? { get set }

	var anchorPoint: CGPoint { get set }

	/// Объект, определяющий иконки пинов для MapItem'ов
	///
	/// @discussion Нет дефолтной реализации. Необходимо подставить свой класс, для отображения пинов объектов на карте.
	var imageSateProvider: MapImageStateProviderProtocol? { get set }

	/// Текущий регион карты
	var mapRegion: MapRegion { get }

	/// Текущий зум
	var zoomLevel: Int { get }

	/// Отступ по вертикали в пикселах при фокусировке
	var focusPixelsYOffset: CGFloat { get set }

	/// Изменение зума карты
	///
	/// - Parameter changeValue: Значение изменения зума
	func changeZoomValue(_ changeValue: Int)

	/// Начать отслеживание пользователя
	func startTrackingUser()

	/// Остановить отслеживание пользователя
	func stopTrackingUser()

	/// Переместить карту в определенную координату с зумом
	///
	/// - Parameters:
	///   - coordinate: Необходимая координата
	///   - zoomLevel: Зум
	///   - animated: Анимированно
	func setCenterCoordinate(coordinate: MapCoordinate, zoomLevel: Float, animated: Bool)

	/// Переместить карту в определенную координату c учетом focusPixelsYOffset
	///
	/// - Parameter coordinate: Необходимая координата
	func focus(on coordinate: MapCoordinate)

	/// Переместить карту в определенную координату c учетом focusPixelsYOffset
	///
	/// - Parameter coordinate: Необходимая координата
	/// - animated: Анимированно
	func focus(on coordinate: MapCoordinate, animated: Bool)

	/// Переместить карту в определенную координату с зумом c учетом focusPixelsYOffset
	///
	/// - Parameters:
	///   - coordinate: Необходимая координата
	///   - zoomLevel: Зум
	///   - animated: Анимированно
	func focus(on coordinate: MapCoordinate, zoomLevel: Float, animated: Bool)

	/// Переместить карту к определенному элементу c учетом focusPixelsYOffset
	///
	/// - Parameter item: Элемент
	func focus(on item: MapItem)

	/// Показать определенный прямоугольник на карте
	///
	/// - Parameter mapRect: Прямоугольник карты
	func show(mapRect: MapRect)

	/// Показать прямоугольник карты
	/// - Parameters:
	///   - mapRect: прямоугольник карты
	///   - animation: анимированно
	func show(mapRect: MapRect, animation: Bool)

	/// Показать объекты на карте
	///
	/// - Parameter items: Объекты для добавления на карту
	func add(items: [MapItem])

	/// Показать объект на карте
	///
	/// - Parameter item: Объект для добавления на карту
	func add(item: MapItem)

	/// Показать объект на карте
	/// - Parameters:
	///   - item: Объект для добавления на карту
	///   - toBackground: На задний фон
	///   - selected: Выбран ли?
	func add(item: MapItem, toBackground: Bool, selected: Bool)

	/// Удаление объекта с карты
	///
	/// - Parameter item: Объект для удаления с карты
	func remove(item: MapItem)

	/// Очистка карты
	func clearClusters()

	/// Убрать выделение пина
	func unselectPin()

	/// Выделить пин определенного элемента
	///
	/// - Parameter item: Элемент, чем пин необходимо выделить
	func selectPin(with item: MapItem)

	/// Меняет тему карты
	///
	/// - Parameter enabled: Включить темную тему
	func setNightModeEnabled(_ enabled: Bool)

	/// Показать кастомный пин пользователя
	/// - Parameters:
	///   - pinImage: Картинка местоположения пользователя
	///   - point: Точка пользователя
	func showCustomUserPin(pinImage: UIImage, point: MapCoordinate)

	/// Скрыть кастомныцй пин пользователя
	func hideCustomUserPin()

	/// Показать полилинию
	/// - Parameter polyline: Полилиния
	func showPolyline(_ polyline: MapPolyline)

	/// Убрать полилинию
	/// - Parameter polyline: Полилиния
	func removePolyline(_ polyline: MapPolyline)

	/// Убрать все полилинии
	func clearPolylines()

	/// Добавить аннотацию на карту
	/// - Parameter annotation: Аннотация
	func add(annotation: MapAnnotation)

	/// Убрать все аннотации с карты
	func clearAnnotations()

	func showRouteOnMap(pickupCoordinate: MapCoordinate,
						destinationCoordinate: MapCoordinate,
						completion: ((TimeInterval)-> Void)?)
}

extension FacadeMapProtocol {
	func show(mapRect: MapRect, animation: Bool) {
		show(mapRect: mapRect)
	}

	func showCustomUserPin(pinImage: UIImage, point: MapCoordinate) {}
	func hideCustomUserPin() {}

	func showPolyline(_ polyline: MapPolyline) {}
	func removePolyline(_ polyline: MapPolyline) {}
	func clearPolylines() {}
	func add(item: MapItem, toBackground: Bool, selected: Bool) {}

	func add(annotation: MapAnnotation) {}
	func clearAnnotations() {}
}
