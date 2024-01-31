//
//  AppDelegate.swift
//  AShareIndex
//
//  Created by Kyle Lin on 2024/1/28.
//

import Cocoa
import AppKit
import Alamofire
import SwiftPath

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu = NSMenu(title: "A股指数")
    var dataLen: Int = 10
    var dataItems: Array<NSMenuItem> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print("程序初始化...")
        
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(runUpdateMenuTextTask), userInfo: nil, repeats: true)
        showMenuBar()
        runUpdateMenuTextTask()
        checkUpdate()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func showMenuBar() {
        for _ in 0..<self.dataLen {
            let item = menu.addItem(withTitle: "正在更新...", action: nil, keyEquivalent: "")
            dataItems.append(item)
        }
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        dataItems.append(menu.addItem(withTitle: "当前版本: \(version)", action: nil, keyEquivalent: ""))
        menu.addItem(withTitle: "设置", action: #selector(openSettingsWindowClicked(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "更新指数", action: #selector(updateIndexClicked(_:)), keyEquivalent: "")
        
        // 商店审核不通过， 先注释掉...
//        menu.addItem(withTitle: "检查版本", action: #selector(checkVersionClicked(_:)), keyEquivalent: "")
        
        menu.addItem(withTitle: "开源地址", action: #selector(openSourceClicked(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "退出", action: #selector(quitClicked(_:)), keyEquivalent: "q")
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        statusItem?.menu = menu
        statusItem?.button?.title = "🫣 A股指数"
    }
    
    func checkUpdate() {
        DispatchQueue.global(qos: .background).async {
            let info = Bundle.main.infoDictionary
            let version = info?["CFBundleShortVersionString"] as? String ?? ""
            let versionInt = Int(version.replacingOccurrences(of: ".", with: "")) ?? 0
            let bundleIdentifier = info?["CFBundleIdentifier"] as? String ?? ""
            print(version, versionInt, bundleIdentifier)
            AF.request("https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)").responseString { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    var alertText = "当前版本: \(version)";
                    if let path = JsonPath("$.results.[0].version") {
                        let mapped = try? path.evaluate(with: value) as? String
                        if let mapped = mapped {
                            let mappedInt = Int(mapped.replacingOccurrences(of: ".", with: "")) ?? 0
                            print(mapped, mappedInt)
                            if (versionInt < mappedInt) {
                                alertText = "软件有最新版本， 可以前往App Store进行更新"
                            }
                        }
                    }
                    let menuItem = self.dataItems[self.dataLen]
                    menuItem.title = alertText
                    self.menu.itemChanged(menuItem)
//                    let alert = NSAlert()
//                    alert.addButton(withTitle: "OK")
//                    alert.messageText = alertText
//                    alert.runModal()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc func runUpdateMenuTextTask() {
        DispatchQueue.global(qos: .background).async {
            var code = Config.getIndexSelect() == 0 ? "sh000001" : "sz399001";
            if Config.getCustomCodeSelect() {
                if let value = Config.getCustomCodeText() {
                    if (value != "") {
                        code = value
                    }
                }
            }
            AShareIndexApi.get(code).responseString(encoding: .none) { response in
                switch response.result {
                    case .success(let value):
                        let arr = value.components(separatedBy: ",")
                        print(arr)
                        if (arr.count > 5) {
                            let closeYesterday = Double(arr[2])
                            let close = Double(NSDecimalNumber(string: arr[3]).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)).stringValue)
                            let up = close ?? 0 > closeYesterday ?? 0
                            var title = String(close ?? 0)
                            if code == "sh000001" {
                                title = "上证" + title
                            } else if code == "sz399001" {
                                title = "深证" + title
                            }
                            if up {
                                // 等割
                                title = Config.getUpText() + title
                            } else {
                                // 已割
                                title = Config.getDownText() + title
                            }
                            DispatchQueue.main.async {
                                self.statusItem?.button?.title = title
                            }
                        }
                    case .failure(let error):
                        print(error)
                }
            }
            AShareIndexApi.list(code, scale: 30, datalen: self.dataLen).responseString(encoding: .none) { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    do {
                        let decoder = JSONDecoder()
                        var items = try decoder.decode([AShareIndexItem].self, from: value.data(using: .utf8)!)
                        items.reverse()
                        for (index, item) in items.enumerated() {
                            print(item)
                            let text = item.day + " -> " + item.close
                            DispatchQueue.main.async {
                                let menuItem = self.dataItems[index]
                                menuItem.title = text
                                self.menu.itemChanged(menuItem)
                            }
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }    
    @objc func openSourceClicked(_ sender: NSMenuItem) {
        let url = URL(string: "https://github.com/kylelin1998/AShareIndex")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func checkVersionClicked(_ sender: NSMenuItem) {
        print("检查版本...")
        checkUpdate()
    }
    
    @objc func updateIndexClicked(_ sender: NSMenuItem) {
        print("更新指数...")
        runUpdateMenuTextTask()
        checkUpdate()
    }
    
    @objc func openSettingsWindowClicked(_ sender: NSMenuItem) {
        print("打开窗口...")
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(identifier: NSStoryboard.SceneIdentifier("Main")) as NSWindowController
        windowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

}

