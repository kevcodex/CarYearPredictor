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
        case kannaError(Swift.Error)
    }
    
    // Inputs
    let licensePlate: String
    let stateString: String
    
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
        
        let request = LicensePlateNetworkRequest(parameters: parameters)
        
        let client = MiniNeClient()
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
            
            let make = getFirstText(from: html, with: "//li[@class='ii-brand']//a") ?? ""
            let model = getFirstText(from: html, with: "//li[@class='ii-car']//a") ?? ""
            let year = getFirstText(from: html, with: "//li[@class='ii-calendar']//a") ?? ""
            
            let carInfo = CarInfo(make: make, model: model, year: year)
            
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
}
