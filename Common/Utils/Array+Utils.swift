import Foundation

extension Array where Element == UInt8 {
    
    var data: Data { Data(self) }
}

extension Array where Element == NSNumber {

    func log(_ prefix: String? = nil) {
        
        if let prefix = prefix {
            print("\(prefix): \(self)")
        } else {
            print(self)
        }
    }
}
