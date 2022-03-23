//
//  ItemAnnotation.swift
//  impressions-ios
//
//  Created by 16695982 on 23.11.2021.
//

import Foundation

import Foundation
import MapKit
import Contacts

class ItemAnnotation: NSObject, MKAnnotation{

    var title: String?
	var locationName: String?
	var discipline: String?
    var coordinate: CLLocationCoordinate2D
	var item: MapItem

	var mapItem: MKMapItem? {
	  guard let location = locationName else {
		return nil
	  }

	  let addressDict = [CNPostalAddressStreetKey: location]
	  let placemark = MKPlacemark(
		coordinate: coordinate,
		addressDictionary: addressDict)
	  let mapItem = MKMapItem(placemark: placemark)
	  mapItem.name = title
	  return mapItem
	}


  var image: UIImage?


  init(
	title: String?,
	locationName: String?,
	discipline: String?,
	coordinate: CLLocationCoordinate2D
  ) {
	self.title = title
	self.locationName = locationName
	self.discipline = discipline
	self.coordinate = coordinate
	self.item = MapItem(coordinate: MapCoordinate(latitude: coordinate.latitude,
													longitude: coordinate.longitude))
	super.init()
  }


  init(item: MapItem) {
	  self.item = item
	  self.title = ""
	  self.image = item.image?.unselectedImage
	  coordinate = CLLocationCoordinate2D(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude) //item.coordinate
	  super.init()
  }

  var subtitle: String? {
	return locationName
  }

}
