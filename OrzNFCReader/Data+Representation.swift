//
//  Data+Representation.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined(separator: " ")
    }
    
    var asciiString: String? {
        return String(data: self, encoding: .ascii)
    }
    
    var binString: String {
        return self.map {  String($0, radix: 2) }.joined(separator: " ")
    }
}
