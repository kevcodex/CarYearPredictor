//
//  LicensePlateNetworkRequest.swift
//  App
//
//  Created by Kevin Chen on 1/16/19.
//

import MiniNe
import Foundation

struct LicensePlateNetworkRequest: NetworkRequest {
    var baseURL: URL? {
        return URL(string: "https://infotracer.com")
    }
    
    var path: String {
        return "/plate-lookup/selection/"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String: Any]?
    
    var headers: [String: Any]?
    
    var body: NetworkBody? {
        return nil
    }
}
