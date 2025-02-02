import Foundation

extension Data {
    
    var hexString: String {
        return self.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    var asciiString: String? {
        return String(data: self, encoding: .ascii)
    }
    
    var binString: String {
        return self.map {  String($0, radix: 2) }.joined(separator: " ")
    }
    
    func log(_ prefix: String? = nil) { self.hexString.log(prefix) }
}
