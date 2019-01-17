//
//  LicensePlateController.swift
//  App
//
//  Created by Kevin Chen on 1/16/19.
//

import Foundation

enum Pattern {
    case letter
    case number
}

final class LicensePlateController {
    private let operationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 2
    }
    
    func getAllCarInfo() -> Set<CarInfo> {
        
        var totalCarInfos: Set<CarInfo> = []
        
        for i in 4...8 {
            
            let maxCount = 1
            
            var carInfos: Set<CarInfo> = []
            
            // Keep getting license plates until read set goal count
            while carInfos.count != maxCount {
                
                // Enqueue multiple operations
                for _ in 1...2 {
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
                    
                    let licensePlateOperation = LicensePlateOperation(licensePlate: randomCALicensePlate, state: "ca")
                    
                    let completionBlock = BlockOperation { [weak licensePlateOperation] in
                        guard let result = licensePlateOperation?.result else {
                            return
                        }
                        
                        switch result {
                        case .success(let carInfo):
                            carInfos.insert(carInfo)
                            
                            if carInfos.count == maxCount {
                                self.operationQueue.cancelAllOperations()
                                break
                            }
                            
                        case .failure(let error):
                            switch error {
                            case .IPAddressBlocked:
                                print(error)
                                exit(1)
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
            
            totalCarInfos.formUnion(carInfos)
        }
        
        return totalCarInfos
    }
    
    
    func writeCarInfoIntoCSV() {
        
    }
}
