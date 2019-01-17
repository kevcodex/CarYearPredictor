//
//  LicensePlateOperation.swift
//  App
//
//  Created by Kevin Chen on 1/16/19.
//

import ScriptHelpers
import Foundation
import MiniNe
import Kanna

class LicensePlateOperation: AsyncOperation {
    
    enum Error: Swift.Error {
        case networkError(MiniNeError)
        case noCarInfo
        case IPAddressBlocked
        case kannaError(Swift.Error)
    }
    
    // Inputs
    let licensePlate: String
    let stateString: String
    
    let client = MiniNeClient()
    
    // Outputs
    var result: Result<CarInfo, Error>? {
        didSet {
            finish()
        }
    }
    
    init(licensePlate: String, state: String) {
        
        self.licensePlate = licensePlate
        self.stateString = state
        
        super.init()
    }
    
    override func execute() {
        
        let parameters: [String: Any] = ["plate": licensePlate,
                                         "state": stateString]
        
        // website will block rapid and quick calls
        // x-forwarded-for can act as a "spoof" for this website as
        // it will think this IP is the "original" IP and use this IP
        let randomIPAddress = generateIPAddress()
        let headers: [String: Any] = ["X-Forwarded-For": randomIPAddress]
        
        let request = LicensePlateNetworkRequest(parameters: parameters, headers: headers)
        
        client.send(request: request) { (result) in
            switch result {
            case .success(let response):
                self.scrapHTML(from: response)
            case .failure(let error):
                self.result = Result(error: .networkError(error))
            }
        }
    }
    
    private func scrapHTML(from response: Response) {
        
        do {
            let html = try HTML(html: response.data, encoding: .utf8)
            
            guard let innerHTML = html.innerHTML,
                !innerHTML.contains("You are blocked") else {
                    self.result = Result(error: .IPAddressBlocked)
                    return
            }
            
            guard let make = getFirstText(from: html, with: "//li[@class='ii-brand']//a"),
                let model = getFirstText(from: html, with: "//li[@class='ii-car']//a"),
                let year = getFirstText(from: html, with: "//li[@class='ii-calendar']//a") else {
                    self.result = Result(error: .noCarInfo)
                    return
            }
            
            let carInfo = CarInfo(licensePlate: licensePlate, make: make, model: model, year: year)
            
            self.result = Result(value: carInfo)
        } catch {
            self.result = Result(error: .kannaError(error))
            return
        }
    }
    
    private func getFirstText(from html: HTMLDocument, with path: String) -> String? {
        
        var text: String?
        for node in html.xpath(path) {
            text = node.text
            break
        }
        
        return text
    }
    
    private func generateIPAddress() -> String {
        var values: [String] = []
        
        while values.count != 4 {
            
            guard let randomNumber = (0...255).randomElement() else {
                continue
            }
            
            values.append(String(randomNumber))
        }
        
        return values.joined(separator: ".")
    }
}
