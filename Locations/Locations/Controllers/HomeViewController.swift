//
//  ViewController.swift
//  Locations
//
//  Created by Amit Dhawan on 20/10/17.
//  Copyright © 2017 Amit Dhawan. All rights reserved.
//

import UIKit
import Moya_ObjectMapper
import GoogleMaps
import Moya
import Result

class HomeViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    
    //view model for location data
    fileprivate var locationDataViewModel: LocationDataViewModel?
    
    //provider to fetch data from api
    fileprivate var locationDataProvider: MoyaProvider<LocationData>?
    fileprivate var routeDataProvider: MoyaProvider<RouteData>?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
            locationManager.requestWhenInUseAuthorization()
        }
        MapViewHelper.setMapView(mapView: mapView)
        fetchGistLocationData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Button clicked action
    @IBAction func buttonClicked() {
        //ask user permission for location service if disabled
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                addMyLocationOnMap()
            }
        } else {
            print("Location services are not enabled")
        }
    }

}

extension HomeViewController: CLLocationManagerDelegate {
    
    //MARK: Location Update
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            print("Location services not enabled")
            break
        default: break
        }
    }
}

extension HomeViewController: NetworkResponseDelegate {
    
    /// Retry method for request
    ///
    /// - Parameter target: type of target for which to retry
    func networkRetryRequest(target: TargetType) {}
    
    /// Network response delegate
    ///
    /// - Parameters:
    ///   - result: result
    ///   - target: type of target
    func networkResult(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard case Result.success(let response) = result else {
            return
        }
        switch target {
        case is LocationData:
            do {
               locationDataViewModel  = try response.mapObject(LocationDataViewModel.self)
                guard let array = locationDataViewModel?.arrayLocationPlacemarks else {
                    return
                }
                self.fetchGooglePlacemarkData(placemarkArray: array)
            } catch {
                print(error.localizedDescription)
            }
        case is RouteData:
            do {
                let routeViewModel = try response.mapObject(RouteViewModel.self)
                let polyline = routeViewModel.getPolyLineForMap()
                self.createPolyLineOnMap(polyLine: polyline, placeMarkArray: locationDataViewModel?.arrayLocationPlacemarks!)
            } catch {
                print(error.localizedDescription)
            }
        default: break
        }
    }
}

extension HomeViewController {
    // MARK: API Calls
    
    /// Add current location on map for the user
    func addMyLocationOnMap() {
        mapView?.isMyLocationEnabled = true
    }
    /// Get location data from gist api
    func fetchGistLocationData() {
        let endpoint = LocationData.fetchLocationData
        let plugin = NetworkPluginHelper(viewController: self)
        plugin.delegate = self
        locationDataProvider = MoyaProvider<LocationData>(plugins: [plugin])
        locationDataProvider?.request(endpoint) { result in }
    }
    
    /// Fetch the route from google directions api
    ///
    /// - Parameter placemarkArray: placemark array
    func fetchGooglePlacemarkData(placemarkArray: [PlaceMark]) {
        guard placemarkArray.count > 0 else {
            print("There are no placemarks found in the route")
            return
        }
        let plugin = NetworkPluginHelper(viewController: self)
        plugin.delegate = self
        let routeDataProvider = MoyaProvider<RouteData>(plugins: [plugin])
        let endpoint = RouteData.fetchRouteDataWithParams(params: placemarkArray)
        routeDataProvider.request(endpoint) { result in }
    }
    
    /// Ask MapViewHelper to createPolyline
    ///
    /// - Parameter polyLine: polyline instance
    func createPolyLineOnMap(polyLine: GMSPolyline?, placeMarkArray: [PlaceMark]?) {
        MapViewHelper.createPolylineOnMap(mapView: self.mapView!,placeMarksArray: placeMarkArray!, polyline: polyLine!)
        let placeMark = placeMarkArray?.first
        guard placeMark?.placeLatitude != nil, placeMark?.placeLongitude != nil else {
            return
        }
        let postion = CLLocationCoordinate2D(latitude: Double(placeMark!.placeLatitude!)!, longitude: Double(placeMark!.placeLongitude!)!)
        MapViewHelper.moveMarkerOnPath(path: (polyLine?.path), markerPosition: postion, mapView: self.mapView!, markerImage: UIImage(named: "aeroplane")!)
    }
}
