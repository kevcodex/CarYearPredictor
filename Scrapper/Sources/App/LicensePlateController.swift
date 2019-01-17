//
//  LicensePlateController.swift
//  App
//
//  Created by Kevin Chen on 1/16/19.
//

import Foundation
import ScriptHelpers

enum Pattern {
    case letter
    case number
}

final class LicensePlateController {
    private let operationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    func getAllCarInfo(completeSet: @escaping (Set<CarInfo>) -> Void) {
        
        var blackListedIPs: Set<String> = []
        
        for i in 3...8 {
            
            let maxCount = 100
            
            var carInfos: Set<CarInfo> = []
            
            // Keep getting license plates until read set goal count
            while carInfos.count != maxCount {
                
                // Enqueue multiple operations
                for _ in 1...operationQueue.maxConcurrentOperationCount {
                    let alphabetArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
                    
                    let numberArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                    
                    let caPlateOrder: [Pattern] = [.number, .letter, .letter, .letter, .number, .number, .number]
                    
                    var randomCALicensePlate: String = ""
                    
                    for (index, pattern) in caPlateOrder.enumerated() {
                        switch pattern {
                        case .letter:
                            if let randomLetter = alphabetArray.randomElement() {
                                randomCALicensePlate.append(randomLetter)
                            }
                        case .number:
                            if index == 0 {
                                randomCALicensePlate.append(String(i))
                            } else if let randomNumber = numberArray.randomElement() {
                                randomCALicensePlate.append(randomNumber)
                            }
                        }
                    }
                    
                    guard randomCALicensePlate.count == caPlateOrder.count else {
                        continue
                    }
                    
                    let doesAlreadyHaveCar = carInfos.contains { $0.licensePlate == randomCALicensePlate }
                    
                    guard !doesAlreadyHaveCar else {
                        continue
                    }
                    
                    print(randomCALicensePlate)
                    
                    let licensePlateOperation = LicensePlateOperation(licensePlate: randomCALicensePlate, state: "ca", blackListedIPs: blackListedIPs)
                    
                    let completionBlock = BlockOperation { [weak licensePlateOperation] in
                        guard let result = licensePlateOperation?.result else {
                            return
                        }
                        
                        switch result {
                        case .success(let carInfo):
                            print("Found Car")
                            
                            carInfos.insert(carInfo)
                            
                            if carInfos.count == maxCount {
                                self.operationQueue.cancelAllOperations()
                                completeSet(carInfos)
                                break
                            }
                            
                        case .failure(let error):
                            switch error {
                            case .IPAddressBlocked(let ipAddress):
                                print(error)
                                blackListedIPs.insert(ipAddress)
                            default:
                                print(error)
                            }
                        }
                    }
                    
                    completionBlock.addDependency(licensePlateOperation)
                    
                    operationQueue.addOperations([licensePlateOperation,
                                                  completionBlock],
                                                 waitUntilFinished: false)
                }
                
                operationQueue.waitUntilAllOperationsAreFinished()
            }
        }
    }
    
    
    func writeCarInfoIntoCSV(with carInfos: Set<CarInfo>) throws {
        Console.writeMessage("**Writing data to CSV")
        let workingDirectory = FileManager.default.currentDirectoryPath
        let csvFilePath = workingDirectory + "/data.csv"
        let csvFileURL = URL(fileURLWithPath: csvFilePath)
        
        for carInfo in carInfos {
            
            let items = [carInfo.licensePlate, carInfo.make, carInfo.model, carInfo.year]
            
            try CSVWriter.addNewRowWithItems(items, to: csvFileURL)
        }
    }
}
