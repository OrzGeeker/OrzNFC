@preconcurrency import CryptoTokenKit

extension OrzNFCModel {
    
    func processState(_ state: TKSmartCardSlot.State, of slot: TKSmartCardSlot) {
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
            self.processCard(of: slot)
        @unknown default:
            break
        }
    }
    
    func processCard(of slot: TKSmartCardSlot) {
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
        ACR122UA9.runTests(for: card)
    }
}
