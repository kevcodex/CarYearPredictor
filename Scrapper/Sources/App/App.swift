import Foundation

public final class App {
    public func start() {
        
        let controller = LicensePlateController()
        
        let allCarInfo = controller.getAllCarInfo()
        
        print(allCarInfo)
    }
    
    public init() {}
}
