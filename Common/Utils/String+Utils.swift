import Foundation

extension String {
    
    func log(_ prefix: String? = nil) {
        
        if let prefix = prefix {
            "\(prefix): \(self)".log
        } else {
            self.log
        }
    }
    
    var log: Void { print(self) }
}

extension String {
    func printDebugInfo() {
#if DEBUG
        print("[DEBUG] \(self)")
#endif
    }
}
