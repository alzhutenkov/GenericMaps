//
//  DGisMapView.swift
//  impressions-ios
//
//  Created by Artem Zabludovsky on 20.08.2021.
//  Copyright © 2021 Heads and Hands. All rights reserved.
//

import UIKit
import DGis

/// Константы стиля
struct GISStylingConstants {
	/// Имя бандла по умолчанию
	let defaultNameResource = "MapStyles"

	/// Тип файла
	let typeResource = "bundle"

	/// Путь до файла
	let fileName = "sdk-styles-2021-08-12-09-46-18"

	/// Тип файла 2гис
	let type = "2gis"

	/// Ключ темы устройства
	let themeKeyConstnts = "theme"

	/// Ключ темной темы
	let themeKeyNight = "night"

	/// Ключ светлой темы
	let themeKeyDay = "day"
}

/// Интерфейс конфигурации карты
protocol GISConfigurationProtocol {

	/// Стиль карты
	var styling: GISStylingConstants { get }

	/// Цвет полигонов
	var polygoneColor: Color { get }
}

/// Экземпляр концигурации карты
struct GISConfiguration: GISConfigurationProtocol {

	// MARK: - GISConfigurationProtocol

	let styling = GISStylingConstants()
	let polygoneColor = Color(argb: UInt32(UIColor.red.withAlphaComponent(0.5).hexa))
}

/// Отображение с картой 2ГИС
//swiftlint:disable type_body_length
//swiftlint:disable file_length
final class GISMapView: NSObject, FacadeMapProtocol {
    var anchorPoint: CGPoint
    
    func showRouteOnMap(pickupCoordinate: MapCoordinate, destinationCoordinate: MapCoordinate, completion: ((TimeInterval) -> Void)?) {
        
    }
    

	deinit {
		print("MAP DEINIT")
	}
	/// Выбранный пин
	var selectedPin: Marker?

	/// Выбранный кластер
	var selectedCluster: MapItem?

	/// СДК 2ГИС для работы с картой
	var sdk: DGis.Container

	/// Карта
	var iMapView: IMapView

	/// Модель контрола(кнопки + -)) приближения
	var zoom: ZoomControlModel?

	/// Источник данных об объектах на карте
	var source: GeometryMapObjectSource

	/// Значение приближения по умолчанию
	var zoomValue: Float = 15

	/// Сервисы локации
	var sourceLocation: DGis.Source?

	/// Все объекты на карте
	var mapObjects: [DGis.Marker] = []

	/// Словарь соответсвия объектов карты объектам из СДК
	var objectsMap: [MapItem: Marker] = [:]

	/// Словарь объектов карты и их ID
	var dictionary: [Int: DGis.GeometryMapObject] = [:]

	/// Текущая координата в фокусе
	var mapCoordinate: MapCoordinate?

	/// Позиция камеры
	var cameraPosition: CameraPosition?

	/// Отмененные действия
	var cancellables = [Any]()

	/// Состояние видимого региона
	enum VisibleAreaState {
		/// Внутри
		case inside
		/// Снаружи
		case outside
	}

	/// Состояние видимого региона
	var visibleAreaIndicatorState: VisibleAreaState?

	/// Видимый регион карты
	var visbleRegion: MapVisibleRegion {
		let coordinateNorthEast = MapCoordinate(latitude: geoRect.northEastPoint.latitude.value,
													 longitude: geoRect.northEastPoint.longitude.value)
		let coordinateSouthWest = MapCoordinate(latitude: geoRect.southWestPoint.latitude.value,
													 longitude: geoRect.southWestPoint.longitude.value)
		let coordinateSouthEast = MapCoordinate(latitude: geoRect.southWestPoint.latitude.value,
													 longitude: geoRect.northEastPoint.longitude.value)
		let coordinateNorthWest = MapCoordinate(latitude: geoRect.northEastPoint.latitude.value,
													 longitude: geoRect.southWestPoint.longitude.value)
		let vars = MapVisibleRegion(topRight: coordinateNorthEast,
									topLeft: coordinateNorthWest,
									bottomRight: coordinateSouthEast,
									bottomLeft: coordinateSouthWest)
		return vars
	}

	// MARK: - Initialization

	/// Инициализатор с параметрами
	/// - Parameters:
	///   - sdk: сдк 2гис
	///   - geoRectDelegate: делегат
	///   - configuration: конфигурация
	init(sdk: DGis.Container,
		 configuration: GISConfigurationProtocol = GISConfiguration()) {
		self.configuration = configuration
		styleFactory = sdk.makeStyleFactory
		let options = DGisMapStyleFactory().makeOptions(with: configuration, styleFactory: styleFactory())
		mapFactory = sdk.makeMapFactory(options: options)
		let map = mapFactory.map
		imageFactoryBuilder = { sdk.imageFactory }
		self.sdk = sdk
		self.map = map
		mapFactory.mapView.copyrightAlignment = .topRight
		mapFactory.mapView.copyrightInsets = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 16)
		iMapView = mapFactory.mapView
		mapView = iMapView
		zoom = ZoomControlModel(map: map)
		let builder = sdk.sourceFactory.createGeometryMapObjectSourceBuilder
		source = builder().createSource()
		map.addSource(source: source)
        self.anchorPoint = .zero
		super.init()
		let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
		mytapGestureRecognizer.numberOfTapsRequired = 1
		mapView.addGestureRecognizer(mytapGestureRecognizer)

		detectExtendedVisibleRectChange()

		updateTheme()
		iMapView.showsAPIVersion = false
	}

	/// Отобразить полигон на карте
	/// - Parameter points: точки полигона
	func showPolygon(points: [MapCoordinate]) {

		let  points = points.map { mapCoordinate in
			GeoPoint(latitude: Arcdegree(value: mapCoordinate.latitude),
					 longitude: Arcdegree(value: mapCoordinate.longitude))
		}
		let color = Color(argb: UInt32(UIColor.red.withAlphaComponent(0.5).hexa))
		let options = PolygonOptions(contours: [points], color: color, strokeColor: color)
		let polygon = Polygon(options: options)
		mapObjectManager.addObject(item: polygon)
	}

	/// Преобразовать координату карты в CGPoint
	/// - Parameter mapCoordinate: координата карты
	/// - Returns: координата CGPoint
	func mapCoordinateToPoint(with mapCoordinate: MapCoordinate) -> CGPoint? {
		let geoPoint = GeoPoint(latitude: Arcdegree(value: mapCoordinate.latitude),
								longitude: Arcdegree(value: mapCoordinate.longitude))
		if let geo = map.camera.projection.mapToScreen(point: geoPoint) {
			let mapCoordinate = CGPoint(x: CGFloat(geo.x), y: CGFloat(geo.y))
			return mapCoordinate
		}
		return nil
	}

	/// Центрировать на точке мира
	/// - Parameter point: точка
	/// - Returns: координата точки в системе координат карты
	func screeenToWorld(with point: CGPoint) -> MapCoordinate? {
		let screenPoint = ScreenPoint(x: Float(point.x * UIScreen.main.scale),
									  y: Float(point.y * UIScreen.main.scale))
		if let geo = map.camera.projection.screenToMap(point: screenPoint) {
			let latitude = geo.latitude.value
			let longitude = geo.longitude.value
			let coordinate = MapCoordinate(latitude: latitude, longitude: longitude)
			return coordinate
		}
		return nil
	}

	/// Центрировать карту
	/// - Parameters:
	///   - сoordinate: координата центра
	///   - zoomLevel: уровень приближения
	///   - animated: анимированной
	func setCenterMapCoordinate(сoordinate: MapCoordinate,
								zoomLevel: Float,
								animated: Bool) {
		guard сoordinate.latitude != 0, сoordinate.longitude != 0 else { return }
		let point = GeoPoint(latitude: .init(value: сoordinate.latitude),
							 longitude: .init(value: сoordinate.longitude))
		let cameraPosition = CameraPosition(point: point,
											zoom: .init(value: zoomLevel),
											tilt: .init(value: 0),
											bearing: .init(value: 0))

		let successBlock: (CameraAnimatedMoveResult) -> Void = { _ in }
		let failureBlock: (Future<CameraAnimatedMoveResult>.Error) -> Void = { _ in }
		if animated {
			moveCameraCancellable = map
				.camera
				.move(position: cameraPosition,
					  time: 0.4,
					  animationType: .default)
				.sink(receiveValue: successBlock, failure: failureBlock)
		} else {
			moveCameraCancellable = map
				.camera
				.move(position: cameraPosition)
				.sink(receiveValue: successBlock, failure: failureBlock)
		}
	}

	/// Добавить кластеры на карту
	/// - Parameter clusters: массив кластеров
	func add(items clusters: [MapItem]) {
		clusters.forEach { cluster in
			add(item: cluster)
		}
	}

	/// Показать прямоугольник карты
	/// - Parameter mapRect: прямоугольник для отображения
	func show(mapRect: MapRect) {
		show(mapRect: mapRect, animation: false)
	}

	/// Показать прямоугольник карты
	/// - Parameters:
	///   - mapRect: прямоугольник карты
	///   - animation: анимированно
	func show(mapRect: MapRect, animation: Bool) {
		let botttomRight = GeoPoint(latitude: Arcdegree(value: mapRect.bottomRight.latitude),
									longitude: Arcdegree(value: mapRect.bottomRight.longitude))
		let bottomLeft = GeoPoint(latitude: Arcdegree(value: mapRect.bottomRight.latitude),
								  longitude: Arcdegree(value: mapRect.topLeft.longitude))
		let topLeft = GeoPoint(latitude: Arcdegree(value: mapRect.topLeft.latitude),
							   longitude: Arcdegree(value: mapRect.topLeft.longitude))
		let topRight = GeoPoint(latitude: Arcdegree(value: mapRect.topLeft.latitude),
								longitude: Arcdegree(value: mapRect.bottomRight.longitude))
		let geometry = PolygonGeometry(contours: [[botttomRight, bottomLeft, topLeft, topRight]])
		let position = calcPosition(camera: map.camera,
									geometry: geometry,
									tilt: Tilt(value: 0),
									bearing: Arcdegree(value: 0))
		setCenterMapCoordinate(сoordinate: MapCoordinate(latitude: position.point.latitude.value,
														  longitude: position.point.longitude.value),
							   zoomLevel: position.zoom.value,
							   animated: animation)
	}

	/// Добавить точку на карту
	/// - Parameters:
	///   - cluster: кластер
	///   - toBackground: на задний план
	func add(item: MapItem, toBackground: Bool = false) {
		add(item: item, toBackground: toBackground, selected: selectedCluster == item)
	}

	/// Добавить точку на карту
	/// - Parameters:
	///   - item: Точка
	///   - toBackground: добавить на задний план
	///   - selected: выбрать
	func add(item: MapItem, toBackground: Bool, selected: Bool) {
		guard let icon = image(for: item, selected: selected, toBackground: toBackground) else { return }
		let point = GeoPointWithElevation(latitude: Arcdegree(value: item.coordinate.latitude),
										  longitude: Arcdegree(value: item.coordinate.longitude))
		let options = MarkerOptions(position: point,
									icon: imageFactory.make(image: icon),
									anchor: .init(x: 0.5, y: 1),
									userData: item)

		if let existedObject = objectsMap[item] {
			mapObjectManager.removeObject(item: existedObject)
		}
		let marker = Marker(options: options)
		mapObjectManager.addObject(item: marker)
		if selected {
			selectedPin = marker
		}
		objectsMap[item] = marker
	}

	/// Удалить аннотацию с карты
	/// - Parameter annotation: удаляемая аннотация
	func removeAnnotation(annotation: MapItem) {
		if let marker = objectsMap[annotation] {
			mapObjectManager.removeObject(item: marker)
			objectsMap.removeValue(forKey: annotation)
			if annotation == selectedCluster {
				selectedPin = nil
			}
		}
	}

	/// Очистить кластеры на карте
	func clearClusters() {
		source.clear()
		mapObjectManager.removeAll()
		objectsMap.removeAll()
	}

	// MARK: Actions

	@objc func tap(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let location: CGPoint = sender.location(in: sender.view)
			let mapLocation = location.applying(self.toMap)
			let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
			let tapRadius = ScreenDistance(value: Float(5))
			let cancel = self.map.getRenderedObjects(centerPoint: tapPoint, radius: tapRadius)
				.sinkOnMainThread(receiveValue: { [weak self] infos in
					guard let self = self else { return }
					if let item = infos.first?.item.item.userData as? MapItem, item.canBeSelected {
						self.delegate?.mapView(self, didSelect: item)
						self.selectPin(with: item)
					}
					if let item = infos.first?.item.item.userData as? MapPolyline {
						self.delegate?.mapView(self, didSelect: item)
					}
					if let item = infos.first?.item.item.userData as? MapAnnotation {
						self.delegate?.mapView(self, didSelect: item)
					}
				},
				failure: { _ in })
			self.cancellable = cancel
		}
	}

	/// Смена темы в СТ
	func onDayShift() {
		map.attributes.setAttributeValue(name: configuration.styling.themeKeyConstnts,
										 value: .string(configuration.styling.themeKeyDay))
	}

	/// Смена темы в ТТ
	func onNightShift() {
		map.attributes.setAttributeValue(name: configuration.styling.themeKeyConstnts,
										 value: .string(configuration.styling.themeKeyNight))
	}

	/// Изменился видимый регион карты
	func detectExtendedVisibleRectChange() {
		let visibleRectChannel = self.map.camera.visibleRect
		formInitialVisibleRect(from: visibleRectChannel)
		initialRectCancellable = map.camera.visibleRectChannel.sinkOnMainThread { [weak self] rect in
			self?.timer?.invalidate()
			self?.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
				self?.updateVisibleRect(rect)
			})
		}
	}

	// MARK: - FacadeMapProtocol

	weak var delegate: FacadeMapDelegate?
	var mapView: UIView
	var imageSateProvider: MapImageStateProviderProtocol?
	var visibleRegion: MapVisibleRegion { visbleRegion }
	var zoomLevel: Int { visibleRegion.zoom }
	var mapRegion: MapRegion {
		let region = visbleRegion
		let minLat = min(region.topLeft.latitude, region.topRight.latitude,
						 region.bottomLeft.latitude, region.bottomRight.latitude)
		let maxLat = max(region.topLeft.latitude, region.topRight.latitude,
						 region.bottomLeft.latitude, region.bottomRight.latitude)
		let minLong = min(region.topLeft.longitude, region.topRight.longitude,
						  region.bottomLeft.longitude, region.bottomRight.longitude)
		let maxLong = max(region.topLeft.longitude, region.topRight.longitude,
						  region.bottomLeft.longitude, region.bottomRight.longitude)
		let span = MapRegionSize(latitudeDelta: maxLat - minLat,
								 longitudeDelta: maxLong - minLong)
		let mapRegion = MapRegion(center: MapCoordinate(latitude: (maxLat + minLat) / 2,
															 longitude: (maxLong + minLong) / 2),
								  span: span)
		return mapRegion
	}
	var focusPixelsYOffset: CGFloat = 0

	func changeZoomValue(_ changeValue: Int) {
		let camera = self.map.camera
		let position = camera.position
		zoomValue = Float(changeValue) + position.zoom.value
		let cameraPosition = CameraPosition(point: position.point,
											zoom: .init(value: zoomValue),
											tilt: .init(value: position.tilt.value),
											bearing: .init(value: position.bearing.value))
		let successBlock: (CameraAnimatedMoveResult) -> Void = { _ in }
		let failureBlock: (Future<CameraAnimatedMoveResult>.Error) -> Void = { _ in }

		moveCameraCancellable = map
			.camera
			.move(
				position: cameraPosition,
				time: 0.35,
				animationType: .default
			).sink(receiveValue: successBlock, failure: failureBlock)
	}

	func startTrackingUser() {
		if !addedUserLocationSource {
			addedUserLocationSource = true
			let source = MyLocationMapObjectSource(context: sdk.context, directionBehaviour: .followSatelliteHeading)
			sourceLocation = source
			map.addSource(source: source)
		}
	}

	func stopTrackingUser() {
		guard let source = sourceLocation else { return }
		map.removeSource(source: source)
		addedUserLocationSource = false
	}

	func setCenterCoordinate(coordinate: MapCoordinate, zoomLevel: Float, animated: Bool) {
		focus(on: coordinate, zoomLevel: zoomLevel, animated: animated)
	}

	func focus(on coordinate: MapCoordinate) { focusOnItem(with: coordinate) }

	func focus(on coordinate: MapCoordinate, animated: Bool) { focusOnItem(with: coordinate, animated: animated) }

	func focus(on coordinate: MapCoordinate, zoomLevel: Float, animated: Bool) {
		setCenterMapCoordinate(сoordinate: coordinate, zoomLevel: zoomLevel, animated: animated)
	}

	func focus(on item: MapItem) {
		focusOnItem(item: item)
	}

	func add(item: MapItem) {
		add(item: item, toBackground: item.toBackground)
	}

	func remove(item: MapItem) {
		removeAnnotation(annotation: item)
	}

	func unselectPin() {
		if let selectedPin = selectedPin,
		   let selectedCluster = selectedCluster,
		   let image = image(for: selectedCluster, selected: false, toBackground: selectedCluster.toBackground),
			selectedCluster.canBeSelected {
			selectedPin.icon = imageFactory.make(image: image)
		}

		selectedCluster = nil
		selectedPin = nil
	}

	func selectPin(with clusterItem: MapItem) {
		unselectPin()
		if let marker = objectsMap[clusterItem],
		   let image = image(for: clusterItem, selected: true, toBackground: false) {
			marker.icon = imageFactory.make(image: image)
			selectedPin = marker
			selectedCluster = clusterItem
		}
	}

	func focusOnItem(with mapCoordinate: MapCoordinate, animated: Bool = true) {
		let first = screeenToWorld(with: CGPoint(x: 100, y: 0))
		let second = screeenToWorld(with: CGPoint(x: 100, y: -focusPixelsYOffset / UIScreen.main.scale))
		let delta = (first?.latitude ?? 0) - (second?.latitude ?? 0)
		var point = mapCoordinate
		if delta > 0 {
			point.latitude -= delta
		}

		let position = map.camera.position
		setCenterMapCoordinate(сoordinate: MapCoordinate(latitude: point.latitude,
															   longitude: point.longitude),
							   zoomLevel: position.zoom.value,
							   animated: animated)
	}

	func focusOnItem(item: MapItem) {
		focusOnItem(with: item.coordinate)
	}

	func setNightModeEnabled(_ enabled: Bool) {
		let styling = configuration.styling
		let key = enabled ? styling.themeKeyNight : styling.themeKeyDay
		iMapView.appearance = .universal(.init(name: key))
	}

	var userCusomPin: Marker?

	func showCustomUserPin(pinImage: UIImage, point: MapCoordinate) {
		hideCustomUserPin()
		let options = MarkerOptions(position: .init(latitude: .init(value: point.latitude),
													longitude: .init(value: point.longitude)),
									icon: sdk.imageFactory.make(image: pinImage))
		let marker = Marker(options: options)
		userCusomPin = marker
		mapObjectManager.addObject(item: marker)
	}

	func hideCustomUserPin() {
		if let userCusomPin = userCusomPin {
			mapObjectManager.removeObject(item: userCusomPin)
		}
	}

	var polylines: [MapPolyline: Polyline] = [:]

	func showPolyline(_ polyline: MapPolyline) {
		let points = polyline.coordinates.map { coordinate in
			GeoPoint(latitude: Arcdegree(value: coordinate.latitude),
					 longitude: Arcdegree(value: coordinate.longitude))
		}

		let color = Color(argb: UInt32(polyline.color.hexa))
		let options = PolylineOptions(points: points,
									  width: .init(value: Float(polyline.width)),
									  color: color, erasedPart: 0,
									  dashedPolylineOptions: nil, gradientPolylineOptions: nil,
									  visible: true,
									  userData: polyline,
									  zIndex: ZIndex(value: UInt32(polyline.zIndex)))

		let polylineObject = Polyline(options: options)
		mapObjectManager.addObject(item: polylineObject)
		polylines[polyline] = polylineObject
	}

	func removePolyline(_ polyline: MapPolyline) {
		if let polylineObject = polylines[polyline] {
			mapObjectManager.removeObject(item: polylineObject)
			polylines.removeValue(forKey: polyline)
		}
	}

	func clearPolylines() {
		polylines.values.forEach { mapObjectManager.removeObject(item: $0) }
		polylines.removeAll()
	}

	var annotations: [Marker] = []

	func add(annotation: MapAnnotation) {
		let geoPosition = annotation.coordinate
		let options = MarkerOptions(position: .init(latitude: .init(value: geoPosition.latitude),
													longitude: .init(value: geoPosition.longitude)),
									icon: sdk.imageFactory.make(image: annotation.image),
									anchor: .init(x: 0.5, y: 1),
									userData: annotation,
									zIndex: ZIndex(value: UInt32(annotation.zIndex)))
		let marker = Marker(options: options)
		mapObjectManager.addObject(item: marker)
		annotations.append(marker)
	}

	func clearAnnotations() {
		annotations.forEach { mapObjectManager.removeObject(item: $0) }
		annotations.removeAll()
	}

	// MARK: Private

	/// Константы
	private enum Constants {
		/// Радиус обработки нажатия на карте
		static let tapRadius = ScreenDistance(value: 1)

		/// Начальный радиус обновления карты
		static let initialRectExpansionRatio = 1.5
	}
	private let map: Map
	private var moveCameraCancellable: Cancellable?
	private var cancellable: Cancellable?
	private var initialRect: GeoRect?
	private var initialRectCancellable: Cancellable?
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private var timer: Timer?
	private let configuration: GISConfigurationProtocol
	private var addedUserLocationSource = false
	private let toMap: CGAffineTransform = {
		let scale = UIScreen.main.nativeScale
		return CGAffineTransform(scaleX: scale, y: scale)
	}()

	private var geoRect: GeoRect = GeoRect(southWestPoint: GeoPoint(latitude: Arcdegree(value: 0),
																	longitude: Arcdegree(value: 0)),
										   northEastPoint: GeoPoint(latitude: Arcdegree(value: 0),
																	longitude: Arcdegree(value: 0)))

	private let imageFactoryBuilder: () -> DGis.IImageFactory
	private lazy var imageFactory = imageFactoryBuilder()
	private let styleFactory: () -> DGis.IStyleFactory
	private let mapFactory: DGis.IMapFactory
}

// MARK: Private
private extension GISMapView {
	private func formInitialVisibleRect(from rect: GeoRect) {
		initialRect = rect.expanded(by: Constants.initialRectExpansionRatio)
	}

	private func updateVisibleRect(_ rect: GeoRect) {
		geoRect = rect
		delegate?.mapView(self, didChange: mapRegion, visibleRegion: visbleRegion)
	}

	private func updateTheme() {
		let styling = configuration.styling
		let key = styling.themeKeyDay
		iMapView.appearance = .universal(.init(name: key))
	}

	private func image(for item: MapItem, selected: Bool, toBackground: Bool) -> UIImage? {
		let imageState = imageSateProvider?.image(for: item, currentZoom: visibleRegion.zoom)
		var clusterImage: UIImage?
		if selected, let image = imageState?.selectedImage {
			clusterImage = image
		} else if toBackground, let image = imageState?.backgroundImage {
			clusterImage = image
		} else if !toBackground, let image = imageState?.unselectedImage {
			clusterImage = image
		} else if selected, let image = item.image?.selectedImage {
			clusterImage = image
		} else if let image = item.image?.unselectedImage {
			clusterImage = image
		}

		return clusterImage
	}
}
