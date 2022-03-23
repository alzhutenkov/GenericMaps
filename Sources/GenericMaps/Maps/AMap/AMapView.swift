//
//  AMapView.swift
//  impressions-ios
//
//  Created by 16695982 on 23.11.2021.
//

import Foundation
import MapKit

/// Отображение с картой 2ГИС
//swiftlint:disable type_body_length
//swiftlint:disable file_length
final class AMapView: NSObject, FacadeMapProtocol {

	func focus(on coordinate: MapCoordinate, zoomLevel: Float, animated: Bool) {
		setCenterMapCoordinate(сoordinate: coordinate,
							   zoomLevel: zoomLevel,
							   animated: animated)
	}


	// Выбранный пин
	var selectedPin: ItemAnnotation?

	var anchorPoint: CGPoint = .init(x: 0.5, y: 0.5)

	/// Выбранный кластер
	var selectedCluster: MapItem?

	private var itemAnnotations = [ItemAnnotation]()
	private var mapObjects = [MapItem: ItemAnnotation]()

	// MARK: - Initialization

	/// Инициализатор с параметрами
	/// - Parameters:
	///   - sdk: сдк 2гис
	///   - geoRectDelegate: делегат
	///   - configuration: конфигурация
	override init(){
		super.init()

	}

	func getCoordinateFromMapRectanglePoint(x:Double, y:Double) -> CLLocationCoordinate2D {
		let mapPoint:MKMapPoint = MKMapPoint(x: x, y: y)
		return mapPoint.coordinate
	}

	func getNECoordinate(mRect:MKMapRect) -> CLLocationCoordinate2D {
		return getCoordinateFromMapRectanglePoint(x: mRect.maxX, y:mRect.minY)
	}

	// remember: use MaxY for South, because 0,0 is the top left corner
	func getSECoordinate(mRect:MKMapRect) -> CLLocationCoordinate2D {
		return getCoordinateFromMapRectanglePoint(x: mRect.maxX, y:mRect.maxY)
	}

	func getSWCoordinate(mRect:MKMapRect) -> CLLocationCoordinate2D {
		return getCoordinateFromMapRectanglePoint(x: mRect.minX, y:mRect.maxY)
	}

	func getNWCoordinate(mRect:MKMapRect) -> CLLocationCoordinate2D {
		return getCoordinateFromMapRectanglePoint(x:  mRect.minX, y:mRect.minY)
	}

	//let mRect:MKMapRect = mapview.visibleMapRect

	//	println(“getNECoordinate:: \(getNECoordinate(mRect).latitude), \(getNECoordinate(mRect).longitude)”)
	//	println(“getSECoordinate:: \(getSECoordinate(mRect).latitude), \(getSECoordinate(mRect).longitude)”)
	//	println(“getSWCoordinate:: \(getSWCoordinate(mRect).latitude), \(getSWCoordinate(mRect).longitude)”)
	//	println(“getNWCoordinate:: \(getNWCoordinate(mRect).latitude), \(getNWCoordinate(mRect).longitude)”)
	/// Видимый регион карты
	var visibleRegion: MapVisibleRegion {

		let rect = self.mkMapView.visibleMapRect
		//
		let coordinateNorthEast = MapCoordinate(latitude: getNECoordinate(mRect: rect).latitude,
												longitude: getNECoordinate(mRect:rect).longitude)
		let coordinateSouthWest = MapCoordinate(latitude: getSWCoordinate(mRect:rect).latitude,
												longitude: getSWCoordinate(mRect:rect).longitude)
		let coordinateSouthEast = MapCoordinate(latitude: getSECoordinate(mRect:rect).latitude,
												longitude: getSECoordinate(mRect:rect).longitude)
		let coordinateNorthWest = MapCoordinate(latitude: getNWCoordinate(mRect:rect).latitude,
												longitude: getNWCoordinate(mRect:rect).longitude)


		//

		let vars = MapVisibleRegion(topRight: coordinateNorthEast,
									topLeft: coordinateNorthWest,
									bottomRight: coordinateSouthEast,
									bottomLeft: coordinateSouthWest)
		//		let maxX = self.mkMapView.visibleMapRect.maxX
		//		let maxY = self.mkMapView.visibleMapRect.maxY
		//		let minY = self.mkMapView.visibleMapRect.minY
		//		let minX = self.mkMapView.visibleMapRect.minX
		//
		//		let bottomRight = screeenToWorld(with: CGPoint(x: maxX,y: maxY))
		//		let bottomLeft = screeenToWorld(with: CGPoint(x: minX,y: maxY))
		//		let topLeft = screeenToWorld(with: CGPoint(x: minX,y:minY))
		//		let topRight = screeenToWorld(with: CGPoint(x: minY,y: maxX))
		//		let vars = MapVisibleRegion(topRight: topRight,
		//									topLeft:topLeft,
		//									bottomRight: bottomRight,
		//									bottomLeft: bottomLeft)
		return vars
	}


	/// Центрировать на точке мира
	/// - Parameter point: точка
	/// - Returns: координата точки в системе координат карты
	func screeenToWorld(with point: CGPoint) -> MapCoordinate {

		let point =	self.mkMapView.convert(point, toCoordinateFrom: self.mkMapView)

		return MapCoordinate(latitude: point.latitude, longitude: point.longitude)
	}

	func add(item: MapItem) {

		self.add(item: item, toBackground: false, selected: false)
	}

	func add(item: MapItem, toBackground: Bool, selected: Bool) {
		let itemAnnotation: ItemAnnotation = ItemAnnotation(item: item)
		//guard let icon = image(for: item, selected: selected, toBackground: toBackground) else { return }
		if let image = item.image?.selectedImage {
			itemAnnotation.image = image
		}
		mapObjects[item] = itemAnnotation
		self.itemAnnotations.append(itemAnnotation)
		self.mkMapView.addAnnotation(itemAnnotation)

	}

	func add(items: [MapItem]) {
		items.forEach { item in
			add(item: item)
		}

	}


	func show(mapRect: MapRect) {
		mkMapView.showAnnotations(mkMapView.annotations, animated: true)

	}

	func show(mapRect: MapRect, animation: Bool) {
		let region = MKCoordinateRegion(center:.init(latitude: mapRect.mapRegion.center.latitude,
													  longitude: mapRect.mapRegion.center.longitude),
										span: .init(latitudeDelta: mapRect.mapRegion.span.latitudeDelta,
													longitudeDelta: mapRect.mapRegion.span.longitudeDelta))
		let rect = MKMapRectForCoordinateRegion(region: region)
		mkMapView.setVisibleMapRect(rect, animated: true)
	}


	let mkMapView = MKMapView()
	var mapView: UIView {
		mkMapView.delegate = self
		return mkMapView
	}

	/// Текущая координата в фокусе
	var mapCoordinate: MapCoordinate?

	var delegate: FacadeMapDelegate?

	var imageSateProvider: MapImageStateProviderProtocol?

	var mapRegion: MapRegion {
		return MapRegion(center: MapCoordinate(latitude: mkMapView.region.center.latitude,
											   longitude: mkMapView.region.center.longitude),
						 span: MapRegionSize(latitudeDelta: mkMapView.region.span.latitudeDelta, longitudeDelta:mkMapView.region.span.longitudeDelta))
	}

	var currentZoomLevel: Int  {
//		guard mkMapView.frame.size.width > 0 else { return 10 }
//		let zoomParam = 360 * Int(((mkMapView.frame.size.width / 256)))
//		return Int(log2(Double(zoomParam)) / self.mkMapView.region.span.longitudeDelta + 1)
		return visibleRegion.zoom
	}

	var zoomLevel: Int { currentZoomLevel }

	var focusPixelsYOffset: CGFloat = 0

	func changeZoomValue(_ changeValue: Int) {

		//let zoom = MKMapView.CameraZoomRange()
		let zoomLevel = currentZoomLevel + changeValue
		setCenterCoordinate(self.mkMapView.centerCoordinate, zoomLevel: zoomLevel, animated: true)
		//self.mkMapView.setCameraZoomRange(zoom, animated: true)
	}

	func setZoomLevel(_ zoomLevel: Int) {
		setCenterCoordinate(self.mkMapView.centerCoordinate, zoomLevel: zoomLevel, animated: true)
	}


	func setCenterCoordinate(
		_ centerCoordinate: CLLocationCoordinate2D,
		zoomLevel: Int,
		animated: Bool
	) {
		let minZoomLevel = min(zoomLevel, 28)

		let span = mkMapView.coordinateSpan(centerCoordinate, andZoomLevel: minZoomLevel)
		let region = MKCoordinateRegion(center: centerCoordinate, span: span)

		mkMapView.setRegion(region, animated: animated)
	}

	func startTrackingUser() {

		// let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
		//		let region = MKCoordinateRegion(
		//	center: oahuCenter.coordinate,
		//	latitudinalMeters: 50000,
		//	longitudinalMeters: 60000)
		//  mapView.setCameraBoundary(
		//	MKMapView.CameraBoundary(coordinateRegion: region),
		//	animated: true)

	}

	func stopTrackingUser() {

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
		setCenterCoordinate(CLLocationCoordinate2D(latitude: сoordinate.latitude,
												   longitude: сoordinate.longitude),
							zoomLevel: Int(zoomLevel) ,animated: animated)


	}

	func setCenterCoordinate(coordinate: MapCoordinate, zoomLevel: Float, animated: Bool) {
		setCenterCoordinate(CLLocationCoordinate2D(latitude: coordinate.latitude,
												   longitude: coordinate.longitude),
							zoomLevel: Int(zoomLevel) ,animated: animated)
	}

	func focus(on coordinate: MapCoordinate) { focusOnItem(with: coordinate) }

	func focus(on coordinate: MapCoordinate, animated: Bool) { focusOnItem(with: coordinate, animated: animated) }


	func focusOnItem(with mapCoordinate: MapCoordinate, animated: Bool = true) {
		let first = screeenToWorld(with: CGPoint(x: 100, y: 0))
		let second = screeenToWorld(with: CGPoint(x: 100, y: -focusPixelsYOffset / UIScreen.main.scale))
		let delta = first.latitude - second.latitude
		var point = mapCoordinate
		if delta > 0 {
			point.latitude -= delta
		}

		let position = self.mkMapView.camera.centerCoordinate
		setCenterMapCoordinate(сoordinate: MapCoordinate(latitude: point.latitude,
														 longitude: point.longitude),
							   zoomLevel: Float(zoomLevel),
							   animated: animated)
	}


	func focus(on item: MapItem) {
		self.focus(on: item.coordinate)
	}

	func remove(item: MapItem) {
		if let anotatation: MKAnnotation = mapObjects[item] {
			mkMapView.removeAnnotation(anotatation)
		}

	}

	func clearClusters() {

		itemAnnotations.forEach { mkMapView.removeAnnotation($0) }
		//mkMapView.rem

	}

	func clearAnnotations() {
		itemAnnotations.forEach { mkMapView.removeAnnotation($0) }
	}

	func unselectPin() {
		if let selectedPin = selectedPin,
		   let selectedCluster = selectedCluster,
		   let image = image(for: selectedCluster, selected: false, toBackground: selectedCluster.toBackground),
		   selectedCluster.canBeSelected {
			//selectedPin.icon = imageFactory.make(image: image)
		}

		selectedCluster = nil
		selectedPin = nil
	}

	func selectPin(with clusterItem: MapItem) {
		unselectPin()
		//if let marker = objectsMap[clusterItem],
		let image = image(for: clusterItem, selected: true, toBackground: false)
		//marker.icon = imageFactory.make(image: image)
		//selectedPin = marker
		selectedCluster = clusterItem

	}


	func setNightModeEnabled(_ enabled: Bool) {

	}
}

extension AMapView {
	
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

extension AMapView: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		let item = annotation as? ItemAnnotation

		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")

		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: item, reuseIdentifier: "annotationView")
		}

		annotationView?.image = item?.image
		annotationView?.canShowCallout = false
		annotationView?.layer.anchorPoint = anchorPoint

		return annotationView
	}

	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
		delegate?.mapView(self, didChange: mapRegion, visibleRegion: visibleRegion)
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
		delegate?.mapView(self, didChange: mapRegion, visibleRegion: visibleRegion)
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
		delegate?.mapView(self, didChange: mapRegion, visibleRegion: visibleRegion)
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
		selectedPin = view.annotation as? ItemAnnotation
		selectedCluster = selectedPin?.item
		selectedPin?.image = selectedCluster?.image?.selectedImage
		view.image = selectedPin?.image
		if let selected = selectedPin?.item {
			self.delegate?.mapView(self, didSelect: selected)
		}

		mkMapView.deselectAnnotation(view.annotation, animated: false)

	}

	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
		selectedPin?.image = selectedCluster?.image?.unselectedImage
		view.image = selectedPin?.image
		selectedPin = nil
		selectedCluster = nil

	}

	func mapView(
		_ mapView: MKMapView,
		annotationView view: MKAnnotationView,
		calloutAccessoryControlTapped control: UIControl
	) {
		guard let artwork = view.annotation as? ItemAnnotation else {
			return
		}

		let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		artwork.mapItem?.openInMaps(launchOptions: launchOptions)
	}
}


let MERCATOR_OFFSET: Double = 268435456 // swiftlint:disable:this identifier_name
let MERCATOR_RADIUS: Double = 85445659.44705395 // swiftlint:disable:this identifier_name
struct PixelSpace {
	public var x: Double // swiftlint:disable:this identifier_name
	public var y: Double // swiftlint:disable:this identifier_name
}

fileprivate extension MKMapView {
	func coordinateSpan(_ centerCoordinate: CLLocationCoordinate2D, andZoomLevel zoomLevel: Int) -> MKCoordinateSpan {
		let space = pixelSpace(fromLongitue: centerCoordinate.longitude, withLatitude: centerCoordinate.latitude)

		// determine the scale value from the zoom level
		let zoomExponent = 20 - zoomLevel
		let zoomScale = pow(2.0, Double(zoomExponent))

		// scale the map’s size in pixel space
		let mapSizeInPixels = self.bounds.size
		let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
		let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale

		// figure out the position of the top-left pixel
		let topLeftPixelX = space.x - (scaledMapWidth / 2)
		let topLeftPixelY = space.y - (scaledMapHeight / 2)

		var minSpace = space
		minSpace.x = topLeftPixelX
		minSpace.y = topLeftPixelY

		var maxSpace = space
		maxSpace.x += scaledMapWidth
		maxSpace.y += scaledMapHeight

		// find delta between left and right longitudes
		let minLongitude = coordinate(fromPixelSpace: minSpace).longitude
		let maxLongitude = coordinate(fromPixelSpace: maxSpace).longitude
		let longitudeDelta = maxLongitude - minLongitude

		// find delta between top and bottom latitudes
		let minLatitude = coordinate(fromPixelSpace: minSpace).latitude
		let maxLatitude = coordinate(fromPixelSpace: maxSpace).latitude
		let latitudeDelta = -1 * (maxLatitude - minLatitude)

		return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
	}

	func pixelSpace(fromLongitue longitude: Double, withLatitude latitude: Double) -> PixelSpace {
		let x = round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / 180.0)
		let y = round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / 180.0)) / (1 - sin(latitude * Double.pi / 180.0))) / 2.0) // swiftlint:disable:this line_length
		return PixelSpace(x: x, y: y)
	}

	func coordinate(fromPixelSpace pixelSpace: PixelSpace) -> CLLocationCoordinate2D {
		let longitude = ((round(pixelSpace.x) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / Double.pi
		let latitude = (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelSpace.y) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / Double.pi // swiftlint:disable:this line_length
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
	let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
	let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))


	let a = MKMapPoint(topLeft)
	let b = MKMapPoint(bottomRight)

	return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
}


extension AMapView {

	func showRouteOnMap(pickupCoordinate: MapCoordinate,
						destinationCoordinate: MapCoordinate,
						completion: ((TimeInterval)-> Void)?) {
		let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinate.latitude, longitude: pickupCoordinate.longitude)
		let destinationCoordinate = CLLocationCoordinate2D(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
		showRouteOnMap(pickupCoordinate: pickupCoordinate, destinationCoordinate: destinationCoordinate, completion: completion)
	}
	func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D,
						destinationCoordinate: CLLocationCoordinate2D,
						completion: ((TimeInterval)-> Void)?) {

		let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
		let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

		let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
		let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

		let sourceAnnotation = MKPointAnnotation()

		if let location = sourcePlacemark.location {
			sourceAnnotation.coordinate = location.coordinate
		}

		let destinationAnnotation = MKPointAnnotation()

		if let location = destinationPlacemark.location {
			destinationAnnotation.coordinate = location.coordinate
		}

//		self.mkMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

		let directionRequest = MKDirections.Request()
		directionRequest.source = sourceMapItem
		directionRequest.destination = destinationMapItem
		directionRequest.transportType = .walking

		// Calculate the direction
		let directions = MKDirections(request: directionRequest)

		directions.calculate {
			(response, error) -> Void in

			guard let response = response else {
				if let error = error {
					print("Error: \(error)")
				}
				completion?(0)
				return
			}

			let route = response.routes[0]
			completion?(route.expectedTravelTime)


			self.mkMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

//			let rect = route.polyline.boundingMapRect
//			self.mkMapView.setRegion(MKCoordinateRegion(rect), animated: true)
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

		let renderer = MKPolylineRenderer(overlay: overlay)

		renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)

		renderer.lineWidth = 5.0

		return renderer
	}
}
