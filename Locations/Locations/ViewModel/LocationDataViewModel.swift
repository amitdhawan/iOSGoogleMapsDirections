//
//  LocationDataViewModel.swift
//  Locations
//
//  Created by Amit Dhawan on 21/10/17.
//  Copyright © 2017 Amit Dhawan. All rights reserved.
//

import ObjectMapper

class LocationDataViewModel: NSObject, Mappable {
    var arrayLocationPlacemarks: [PlaceMark]?
    
    // MARK: JSON
    required init?(map: Map) { }
    
    /// Map the respnse data in objects
    ///
    /// - Parameter map: map which has the data
    func mapping(map: Map) {
        var locationString: String?
        locationString <- map["files.Locations.content"]
        guard locationString != nil else {
            print("The location data could not be parsed from network response")
            return
        }
        guard let array = convertToArray(text: locationString!) else {
            print("The location string could not be mapped to array.")
            return
        }
        arrayLocationPlacemarks = getPlacemMarkObjectsFromArray(rawArray: array)
    }
}

extension LocationDataViewModel {
    
    /// Convert string to dictionary
    ///
    /// - Parameter text: text string
    /// - Returns: array of dictionaries
    private func convertToArray(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// Returns the Placemark objects array
    ///
    /// - Parameter rawArray: arrau of dictionaries
    /// - Returns: Arrau of Placemark objects
    private func getPlacemMarkObjectsFromArray(rawArray: [[String: Any]]) -> [PlaceMark] {
        var placeMarkArray = [PlaceMark]()
        for dictionary in rawArray {
            let placeMark = PlaceMark()
            placeMark.placeName = dictionary["name"] as? String
            placeMark.placeAddress = dictionary["address"] as? String
            placeMark.placeLatitude = dictionary["lat"] as? String
            placeMark.placeLongitude = dictionary["long"] as? String
            placeMarkArray.append(placeMark)
        }
        return placeMarkArray
    }
}
