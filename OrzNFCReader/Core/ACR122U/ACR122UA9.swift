//
//  ACR122UA9.swift
//  OrzNFCReader
//
//  Created by joker on 2022/7/12.
//  Copyright © 2022 joker. All rights reserved.
//

import Foundation

/// ACR122U 是一款连机非接触式智能卡读写器
///
/// 可以读写
/// - ISO 14443-4 A 类和 B 类卡
/// - MIFARE®卡
/// - ISO18092 卡以及 FeliCa 标签。
///
/// 由于符合 PC/SC 标准，它可以与现有的 PC/SC 应用相兼容。
/// 作为非接触式标签与个人电脑的中间设备，ACR122U 通过 USB 端口与电脑建立连接并执行电脑发出
/// 的指令，从而实现与非接触式标签的通信或者对外围设备(LED 指示灯或蜂鸣器)进行控制
///
/// 特性
///
/// - USB2.0全速接口
/// - 符合 CCID 标准
/// - 智能卡读写器:
///     - 读写速率高达424kbps
///     - 内置天线用于读写非接触式标签，读取智能卡的距离可达50mm(视标签的类型而定)
///     - 支持ISO 14443第4部分A类和B类卡、Mifare卡、FeliCa卡和全部四种NFC(ISO/IEC 18092)标签
///     - 内建防冲突特性(任何时候都只能访问1张标签)
/// - 应用程序编程接口:
///     - 支持PC/SC
///     - 支持CT-API(通过PC/SC上一层的封装)
/// - 内置外围设备:
///     - 用户可控的双色LED指示灯
///     - 用户可控的蜂鸣器
/// - 支持 AndroidTM OS 3.1 及以上版本
/// - 符合下列标准:
///     - IEC/EN 60950
///     - ISO18092
///     - ISO 14443
///     - CE
///     - FCC
///     - KC
///     - VCCI
///     - MIC
///     - PC/SC
///     - CCID
///     - Microsoft WHQL
///     - RoHS2
///
/// ACR122U 通过符合 USB 1.1 规范的 USB 端口与计算机建立连接，工作于 USB 全速模式，速率为 12Mbps
///
struct ACR122UA9 {
    
    static let name = "ACS ACR122U"
    
    enum Command {
        
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
        
        
        var request: Data {
            switch self {
            case .firmwareVersion:
                return Data([0xFF, 0x00, 0x48, 0x00, 0x00])
            case .piccOpParameter:
                return Data([0xFF, 0x00, 0x50, 0x00, 0x00])
            case .setPiccOpParameter(let picc):
                return Data([0xFF, 0x00, 0x51, picc, 0x00])
            case .setTimeoutParameter(let timeout):
                return Data([0xFF, 0x00, 0x41, timeout, 0x00])
            case .setBuzzStatus(let pollBuzzStatus):
                return Data([0xFF, 0x00, 0x52, pollBuzzStatus, 0x00])
            case .currentStatus:
                return Data([0xFF, 0x00, 0x00, 0x00, 0x02, 0xD4, 0x04])
            case .LEDStatus:
                return Data([0xFF, 0x00, 0x40, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00])
            case .setLEDStatus(let ledStatus):
                return Data([0xFF, 0x00, 0x40, ledStatus, 0x04, 0x00, 0x00, 0x00, 0x00])
            }
        }
    }
    
    enum Status: UInt8 {
        case success = 0x90
        case failure = 0x63
    }
}
