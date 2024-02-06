//
//  ACR122UA9+Request.swift
//  OrzNFCReader
//
//  Created by joker on 2/6/24.
//

import CryptoTokenKit

extension TKSmartCard {
    
    func transmit(_ command: ACR122UA9.Command) async throws -> Data {
        return try await self.transmit(command.bytes.data)
    }
}
