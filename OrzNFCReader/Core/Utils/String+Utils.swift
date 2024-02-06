//
//  String+Utils.swift
//  OrzNFCReader
//
//  Created by joker on 2/6/24.
//

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
