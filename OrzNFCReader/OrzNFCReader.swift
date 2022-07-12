//
//  main.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import CryptoTokenKit

@main
struct OrzNFCReader {
    
    /// 智能卡管理器
    private static let manager: TKSmartCardSlotManager = {
        guard let mgr = TKSmartCardSlotManager.default else {
            fatalError("The com.apple.security.smartcard entitlement is required in order to use TKSmartCardSlotManager.")
        }
        return mgr
    }()
    
    
    static func main() {
        
        guard let slot = manager.slotNamed(ACR122UA9.name) else {
            print("no smart card solt")
            return
        }
        
        if let atr = slot.atr?.bytes {
            print("ATR: \(atr.hexString)")
        }
        print("maxInputLength: \(slot.maxInputLength)")
        print("maxOutputLength: \(slot.maxOutputLength)")
        print("")
        guard let card = slot.makeSmartCard() else {
            print("no smard card on slot")
            return
        }
        
        print("card is valid: \(card.isValid)")
        
        // 异步
        
        var terminal = false
        card.beginSession { reply, error in
            guard reply else {
                print(error?.localizedDescription)
                return
            }
            
            card.transmit(ACR122UA9.Command.setLEDStatus(0x0C).request) { reply, error in
                guard error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                print(reply?.hexString)
                
                terminal = true
            }
        }
        
        
        while !terminal {
            
        }
    }
}
