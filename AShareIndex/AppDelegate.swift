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
        self.runUpdateMenuTextTask()
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
        menu.addItem(withTitle: "设置", action: #selector(openSettingsWindowClicked(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "更新指数", action: #selector(updateIndexClicked(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "检查版本", action: #selector(checkVersionClicked(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "退出", action: #selector(quitClicked(_:)), keyEquivalent: "q")
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        statusItem?.menu = menu
        statusItem?.button?.title = "🫣 A股指数"
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
                            let close = Double(arr[3])
                            let up = close ?? 0 > closeYesterday ?? 0
                            var title = String(close ?? 0)
                            if code == "sh000001" {
                                title = "上证" + title
                            } else if code == "sz399001" {
                                title = "深证" + title
                            }
                            if up {
                                // 等割
                                title = "📈" + title
                            } else {
                                // 已割
                                title = "📉" + title
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
    
    @objc func checkVersionClicked(_ sender: NSMenuItem) {
        print("检查版本...")
        DispatchQueue.global(qos: .background).async {
            let info = Bundle.main.infoDictionary
            print(info)
            let version = info?["CFBundleShortVersionString"] as? String ?? ""
            var bundleIdentifier = info?["CFBundleIdentifier"] as? String ?? ""
            print("")
            print(version, bundleIdentifier)
            
            AF.request("https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)").responseString { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    if let path = JsonPath("$.results.[0].version") {
                        let mapped = try? path.evaluate(with: value) as? String
                        print(mapped)
                        if let mapped = mapped {
                            DispatchQueue.main.async {
                                print(mapped)
                                let alert = NSAlert()
                                alert.addButton(withTitle: "OK")
                                alert.icon = NSImage(named: "index")
                                if (mapped != version) {
                                    alert.messageText = "软件有最新版本， 可以前往App Store进行更新"
                                } else {
                                    alert.messageText = "软件已是最新版本"
                                }
                                alert.runModal()
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @objc func updateIndexClicked(_ sender: NSMenuItem) {
        print("更新指数...")
        runUpdateMenuTextTask()
    }
    
    @objc func openSettingsWindowClicked(_ sender: NSMenuItem) {
        print("打开窗口...")
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(identifier: NSStoryboard.SceneIdentifier("Main")) as NSWindowController
        windowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

}

