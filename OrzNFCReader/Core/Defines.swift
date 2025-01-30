enum CardName: String {
    case mifare_classic_1K
    case mifare_classic_4K
    case mifare_ultralight
    case mifare_mini
    case topaz_jewel
    case feliCa_212K
    case feliCa_424K
    case unknown
}

extension CardName {
    var log: Void { self.rawValue.log("Card Name") }
}

enum CardStandard: String {
    case iso_14443A_Part3
    case unknown
}

extension CardStandard {
    var log: Void { self.rawValue.log("Card Standard") }
}

enum AuthKeyType: UInt8 {
    case A = 0x60
    case B = 0x61
}

import Foundation
struct TransportConfiguration {
    
    static let keyA = Array<UInt8>.init(repeating: 0xFF, count: 6)
    
    static let accessBits = Array<UInt8>.init(arrayLiteral: 0xFF, 0x07, 0x80)
    
    static let byte9 = 0x69
    
    static let keyB = Array<UInt8>.init(repeating: 0xFF, count: 6)
}
