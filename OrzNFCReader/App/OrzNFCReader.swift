//
//  main.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import CryptoTokenKit
import Combine

@main
struct OrzNFCReader {
    
    /// 智能卡管理器
    private static let manager: TKSmartCardSlotManager = {
        guard let mgr = TKSmartCardSlotManager.default
        else {
            fatalError("The com.apple.security.smartcard entitlement is required in order to use TKSmartCardSlotManager.")
        }
        return mgr
    }()
    
    /// 监听是否有读卡器插拔事件
    private static var slotPublisherCancellable: Cancellable?
    
    /// 读卡器插槽
    private static var cardSlots = [String: TKSmartCardSlot]()
    
    /// 读卡器状态监听
    private static var slotStatePublisherCancellables = [String: Cancellable]()
    
    /// 程序入口
    static func main() {
        
        slotPublisherCancellable = manager.publisher(for: \.slotNames).sink { slotNames in
            
            Task {
                
                for slotName in slotNames {
                    
                    guard let slot = await manager.getSlot(withName: slotName)
                    else {
                        "找不到读卡器 \(slotName)".log
                        continue
                    }
                    
                    // 存储读卡器实例
                    cardSlots[slotName] = slot
                    
                    // 监听读卡器状态变化
                    slotStatePublisherCancellables[slotName] = slot.publisher(for: \.state)
                        .filter { $0 != .probing }
                        .removeDuplicates()
                        .sink { state in
                            switch state {
                            case .missing:
                                "读卡器被拔掉了".log
                            case .empty:
                                "没有放上智能卡".log
                            case .muteCard:
                                "智能卡无响应命令".log
                            case .probing:
                                "正在探测智能卡".log
                            case .validCard:
                                "智能卡准备就绪".log
                                processCard(of: slot)
                            @unknown default:
                                fatalError("读卡器未知状态")
                            }
                        }
                }
                
            }
        }
        
        RunLoop.main.run()
    }
}

extension OrzNFCReader {
    
    static func processCard(of slot: TKSmartCardSlot) {
        
        Task {
            
            guard let card = slot.makeSmartCard()
            else {
                "读卡器\(slot.name)上的卡片无效".log
                return
            }
            
            if let atr = card.slot.atr {
                atr.bytes.log("Card ATR")
                atr.protocols.log("Card Protocols")
                slot.name.log("读卡器名称")
                slot.maxInputLength.log("APDU MaxInputLength(Reader -> Card)")
                slot.maxOutputLength.log("APDU MaxOutputLength(Card -> Reader)")
            }
            
            try await card.withSession {
                
                try await ACR122UA9.runTests(for: card)
            }
        }
    }
}
