import Foundation

public final class App {
    public func start() {
        let controller = LicensePlateController()
        
        controller.getLicensePlates()
    }
    
    public init() {}
}

final class LicensePlateController {
    private let operationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 5
    }
    
    func getLicensePlates() {
        
        let licensePlateOperation = LicensePlateOperation(licensePlate: "6TTG646", state: "ca")
        
        let completionBlock = BlockOperation { [weak licensePlateOperation] in
            guard let result = licensePlateOperation?.result else {
                return
            }
            
            switch result {
            case .success(let carInfo):
                print(carInfo)
            case .failure(let error):
                print(error)
            }
        }
        
        completionBlock.addDependency(licensePlateOperation)
        
        operationQueue.addOperations([licensePlateOperation,
                                      completionBlock],
                                     waitUntilFinished: false)
        
        operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    
    func storeLicensePlateIntoCSV() {
        
    }
}
