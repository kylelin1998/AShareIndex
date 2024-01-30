//
//  Config.swift
//  AShareIndex
//
//  Created by Kyle Lin on 2024/1/29.
//

import Cocoa
import LaunchAtLogin

struct Config {
    static func getIndexSelect() -> Int {
        let index = UserDefaults.standard.string(forKey: "_IndexSelect")
        if let index = index {
            return Int(index) ?? 0
        } else {
            return 0
        }
    }
    static func setIndexSelect(value: Int) {
        UserDefaults.standard.set(String(value), forKey: "_IndexSelect")
    }
    
    static func getBootSelect() -> Int {
        return LaunchAtLogin.isEnabled ? 0 : 1
    }
    static func setBootSelect(value: Int) {
        LaunchAtLogin.isEnabled = value == 0
    }
    
    static func getCustomCodeSelect() -> Bool {
        return UserDefaults.standard.bool(forKey: "_CustomCodeSelect")
    }
    static func setCustomCodeSelect(value: Bool) {
        UserDefaults.standard.set(value, forKey: "_CustomCodeSelect")
    }
    static func getCustomCodeText() -> String? {
        return UserDefaults.standard.string(forKey: "_CustomCodeText")
    }
    static func setCustomCodeText(value: String) {
        UserDefaults.standard.set(value, forKey: "_CustomCodeText")
    }
}
