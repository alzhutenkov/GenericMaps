//
//  MarkerView.swift
//  impressions-ios
//
//  Created by 16695982 on 23.11.2021.
//

import Foundation

import MapKit

//class ArtworkMarkerView: MKMarkerAnnotationView {
//  override var annotation: MKAnnotation? {
//	willSet {
//	  // 1
//	  guard let artwork = newValue as? Artwork else {
//		return
//	  }
//	  canShowCallout = true
//	  calloutOffset = CGPoint(x: -5, y: 5)
//	  rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//
//	  // 2
//	  markerTintColor = artwork.markerTintColor
//	  if let letter = artwork.discipline?.first {
//		glyphText = String(letter)
//	  }
//	}
//  }
//}
