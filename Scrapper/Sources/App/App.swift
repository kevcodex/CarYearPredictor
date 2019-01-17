import Foundation
import ScriptHelpers

public final class App {
    public func start() {
        
        let controller = LicensePlateController()
            
        controller.getAllCarInfo { carInfos in
            do {
                try controller.writeCarInfoIntoCSV(with: carInfos)
            } catch {
                Console.writeMessage(error)
            }
        }
        
        print("FINISHED")
    }
    
    public init() {}
}
