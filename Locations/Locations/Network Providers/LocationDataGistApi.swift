//
//  LocationDataGistApi.swift
//  Locations
//
//  Created by Amit Dhawan on 21/10/17.
//  Copyright © 2017 Amit Dhawan. All rights reserved.
//


import Foundation
import Moya

let SUCCESS_CODE = 200

public enum LocationData {
    case fetchLocationData
}

extension LocationData: TargetType {
    
    /// Provide headers if any
    public var headers: [String : String]? {
        return nil
    }
    
    /// Base url/host
    public var baseURL: URL { return URL(string: kGistHost)! }
    
    /// path to be appended to base url
    public var path: String {
        return "/gists/e93424ed96d4c3a833d76f29315cf834" //gist public id
    }
    
    /// type of request method get, post, put etc.
    public var method: Moya.Method {
        return .get
    }

    
    /// type of request
    public var task: Task {
        return .requestPlain
    }
    
    // sample data received from api response
    public var sampleData: Data {
        // swiftlint:disable line_length
        return "[\n  {\n    \"lat\": \"28.5355\",\n    \"lon\": \"77.3910\",\n    \"name\": \"Noida\",\n    \"state\": \"Uttar Pradesh\",\n    \"address\": \"Abcd\",\n  },\n  {\n    \"lat\": \"28.7041\",\n    \"lon\": \"77.1025\",\n    \"name\": \"Delhi\",\n    \"state\": \"Uttar Pradesh\",\n    \"address\": \"Abcd\",\n  },\n  {\n    \"lat\": \"28.4595\",\n    \"lon\": \"77.0266\",\n    \"name\": \"Gurgaon\",\n    \"state\": \"Uttar Pradesh\",\n    \"address\": \"Abcd\",\n  },".data(using: String.Encoding.utf8)!
    }
}

