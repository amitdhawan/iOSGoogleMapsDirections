//
//  MapViewHelper.swift
//  Locations
//
//  Created by Amit Dhawan on 21/10/17.
//  Copyright © 2017 Amit Dhawan. All rights reserved.
//

import GoogleMaps


class CordinatesList: NSObject {
    var path: GMSPath?
    var target: UInt = 0
    
    
    func nextCordinate() -> CLLocationCoordinate2D? {
        target+=1
        if target == path?.count() {
            return nil
        }
        return path!.coordinate(at: target)
    }
}

class MapViewHelper: NSObject {
    
    static var wayPointsMarkers = [GMSMarker]()

    /// Creates map view
    ///
    /// - Returns: MapView instance
    class func setMapView(mapView: GMSMapView) {
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 8.0)
        mapView.camera = camera
    }
    
    /// Create polyline on map
    ///
    /// - Parameters:
    ///   - startPlacemark: start placemark
    ///   - endPlaceMark: end Placemark
    ///   - polyline: polyline path
    class func createPolylineOnMap(mapView:GMSMapView, placeMarksArray: [PlaceMark], polyline: GMSPolyline) {
 
        // Creates a marker in the center of the map.
        guard let startPlaceMark = placeMarksArray.first, startPlaceMark.placeLatitude != nil, startPlaceMark.placeLongitude != nil else {
            print("startPlacemark lat or long is nil")
            return
        }
        guard let endPlaceMark = placeMarksArray.last, endPlaceMark.placeLatitude != nil,  endPlaceMark.placeLongitude != nil else {
            print("endPlacemark lat or long is nil")
            return
        }
        let filteredArray = placeMarksArray.dropLast()
        let wayPointsArray = filteredArray
            .dropFirst()
        // add waypoints on map
        MapViewHelper.addWayPointsMarkerOnMap(mapView: mapView, wayPointsArray: Array(wayPointsArray))
        
        // create custom markers
        var position =
            CLLocationCoordinate2D(latitude: Double(startPlaceMark.placeLatitude!)!, longitude: Double(startPlaceMark.placeLongitude!)!)
        MapViewHelper.createCustomMarker(title: startPlaceMark.placeName!, mapView: mapView, position: position)
        position = CLLocationCoordinate2D(latitude: Double(endPlaceMark.placeLatitude!)!, longitude: Double(endPlaceMark.placeLongitude!)!)
        MapViewHelper.createCustomMarker(title: endPlaceMark.placeName!, mapView: mapView, position: position)
        
        // create polyline
        MapViewHelper.customizePolyline(polyLine: polyline, mapView: mapView)
    }
   
    /// Method to move marker on the path provided on map
    ///
    /// - Parameters:
    ///   - path: path on whoch marker will move
    ///   - OnMap: Map with path
    ///   - markerImage: marker image
    class func moveMarkerOnPath(path: GMSPath?, markerPosition: CLLocationCoordinate2D,mapView: GMSMapView, markerImage: UIImage) {
        guard path != nil else {
            return
        }
        let marker = GMSMarker()
        marker.icon = markerImage
        marker.appearAnimation = .pop
        marker.position = markerPosition
        marker.map = mapView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.isFlat = true
        let coordsList = CordinatesList()
        coordsList.path = path
        marker.userData = coordsList
        MapViewHelper.animateMarkerToNextCordinate(marker: marker, mapView: mapView)
    }
    
    /// create custom markers
    ///
    /// - Parameters:
    ///   - title: title of marker
    ///   - map: map on which marker will be shown
    ///   - position: position of marker
    private class func createCustomMarker(title: String, mapView: GMSMapView, position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.title = title
        marker.position = position
        marker.map = mapView
    }
    
    /// Customize the polyline properties
    ///
    /// - Parameter polyLine: polyLine instance
    private class func customizePolyline(polyLine: GMSPolyline, mapView: GMSMapView) {
        polyLine.strokeWidth = 8
        polyLine.strokeColor = UIColor.blue
        polyLine.map = mapView
    }
    
    /// Animate marker to next cordinate
    ///
    /// - Parameter marker: marker to be moved
    private class func animateMarkerToNextCordinate(marker: GMSMarker, mapView: GMSMapView) {
        if let cordinates = marker.userData as? CordinatesList {
            guard let nextCordinate = cordinates.nextCordinate() else {
                return
            }
            let previousCordinate = marker.position
            let heading = GMSGeometryHeading(previousCordinate, nextCordinate)
            let distance = GMSGeometryDistance(previousCordinate, nextCordinate)
            var timer = 1.0
            if MapViewHelper.isMarkerPostionEqualToWaypointPosition(marker: marker){
                wayPointsMarkers.removeFirst() //remove the waypoint
                timer = 5.0 //delay of 5 sec
                print("WayPoint occured in path")
            }
            let newPosition = GMSCameraPosition.camera(withLatitude: nextCordinate.latitude,
                                                       longitude: nextCordinate.longitude,
                                                       zoom: 8.0)
            mapView.camera = newPosition
            CATransaction.begin()
            // 1km/sec speed of marker
            CATransaction.setAnimationDuration(distance / (40
                * 1000))
            DispatchQueue.main.asyncAfter(deadline: .now() + timer , execute: {
                self.animateMarkerToNextCordinate(marker: marker, mapView: mapView)
            })
            marker.position = nextCordinate
            CATransaction.commit()
            if marker.isFlat {
                marker.rotation = heading
            }
        }
    }
    
    /// Add waypoints on the polyline
    ///
    /// - Parameters:
    ///   - mapView: map on which polyline drawn
    ///   - wayPointsArray: array of waypoints
    private class func addWayPointsMarkerOnMap(mapView: GMSMapView, wayPointsArray: [PlaceMark]) {
        for placemark in wayPointsArray {
            guard placemark.placeLatitude != nil,  placemark.placeLongitude != nil else {
                print("placemark waypoint lat or long is nil")
                continue
            }
            let wayPointMarker = GMSMarker()

            wayPointMarker.position = CLLocationCoordinate2D(latitude: Double(placemark.placeLatitude!)!, longitude: Double(placemark.placeLongitude!)!)
            wayPointMarker.title = placemark.placeName
            wayPointMarker.map = mapView
            let markerImage = UIImage(named: "glow-marker")!
            //creating a marker view
            let markerView = UIImageView(image: markerImage)
            wayPointMarker.iconView = markerView
            wayPointsMarkers.append(wayPointMarker)
        }
    }
    
    /// Check if waypoint is encountered on map while marker moves
    ///
    /// - Parameter marker: marker moving
    /// - Returns: status true or false
    private class func isMarkerPostionEqualToWaypointPosition(marker: GMSMarker) -> Bool{
        let markerLatitude = String(format: "%.1f", marker.position.latitude)
        let markerLongitude = String(format: "%.1f", marker.position.longitude)
        let filteredMarkerArray = wayPointsMarkers.filter { (waypoint) -> Bool in
            let wayPointLatitude =  String(format: "%.1f", waypoint.position.latitude)
            let wayPointLongitude =  String(format: "%.1f", waypoint.position.longitude)
            return wayPointLatitude == markerLatitude &&  wayPointLongitude == markerLongitude
        }
        return filteredMarkerArray.count > 0
    }
}
