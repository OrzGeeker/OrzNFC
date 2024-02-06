//
//  ACR122UA9+Command.swift
//  OrzNFCReader
//
//  Created by joker on 2/6/24.
//

import Foundation

extension ACR122UA9 {
    
    enum Command {
        
        /// 获取PICC的UID
        case serialNumber
        
        /// 获取PICC的ATS
        case ATS
        
        /// 获取读写器固件版本, ASCII字符串
        case firmwareVersion
        
        /// 获取PICC操作参数
        /// PICC 操作参数(默认值 = FFh)
        case piccOpParameter
        
        /// 设置PICC操作参数
        /// bit7 - 自动 PICC 轮询  1: 启用  0:停用
        /// bit6 - 自动ATS生成，每次激活 ISO 14443-4 A 类标签都发送ATS请求   1: 启用  0:停用
        /// bit5 - 轮询时间间隔  1: 250ms  0: 500ms
        /// bit4 - FeliCa 424K   1: 检测 0:跳过
        /// bit3 - FeliCa 212K   1: 检测 0:跳过
        /// bit2 - Topaz             1: 检测 0:跳过
        /// bit1 - ISO 14443 Type B  1: 检测 0:跳过
        /// bit0 - ISO 14443 A 类，要检测 Mifare 标签，必须首先禁用自动 ATS 生成  1: 检测 0:跳过
        case setPiccOpParameter(UInt8)
        
        /// 设置超时参数
        /// 0x00 - 不检查超时
        /// 0x01~0xFE - 以5秒为单位，进行超时设置，即 timeout = n * 5 秒
        /// 0xFF - 一直等待，超时时长无限
        case setTimeoutParameter(UInt8)
        
        /// 获取非接触式接口的当前设置
        case currentStatus
        
        /// 读取当前 LED 的状态
        case LEDStatus
        
        /// 设置 LED 的状态
        case setLEDStatus(uint8)
        
        /// 设置卡片检测期间蜂鸣器输出，默认打开
        /// 0x00 - 关闭蜂鸣器
        /// 0xFF - 打开蜂鸣器
        case setBuzzStatus(UInt8)
        
        /// 设置天线开关
        /// 0x00 - 关闭天线
        /// 0x01 - 打开天线
        case setAntenna(UInt8)
        
        /// 获取当前设置
        case currentSettings
    }
}

extension ACR122UA9.Command {
    
    /// 字节定义
    var bytes: [UInt8] {
        switch self {
        case .serialNumber:
            return [0xFF, 0xCA, 0x00, 0x00, 0x00]
        case .ATS:
            return [0xFF, 0xCA, 0x01, 0x00, 0x00]
        case .firmwareVersion:
            return [0xFF, 0x00, 0x48, 0x00, 0x00]
        case .piccOpParameter:
            return [0xFF, 0x00, 0x50, 0x00, 0x00]
        case .setPiccOpParameter(let picc):
            return [0xFF, 0x00, 0x51, picc, 0x00]
        case .setTimeoutParameter(let timeout):
            return [0xFF, 0x00, 0x41, timeout, 0x00]
        case .setBuzzStatus(let pollBuzzStatus):
            return [0xFF, 0x00, 0x52, pollBuzzStatus, 0x00]
        case .currentStatus:
            return [0xFF, 0x00, 0x00, 0x00, 0x02, 0xD4, 0x04]
        case .LEDStatus:
            return [0xFF, 0x00, 0x40, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00]
        case .setLEDStatus(let ledStatus):
            return [0xFF, 0x00, 0x40, ledStatus, 0x04, 0x00, 0x00, 0x00, 0x00]
        case .setAntenna(let enable):
            return [0xFF, 0x00, 0x00, 0x00, 0x04, 0xD4, 0x32, 0x01, enable]
        case .currentSettings:
            return [0xFF, 0x00, 0x00, 0x00, 0x02, 0xD4, 0x04]
        }
    }
}
