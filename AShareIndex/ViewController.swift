//
//  ViewController.swift
//  AShareIndex
//
//  Created by Kyle Lin on 2024/1/28.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var indexComboBox: NSComboBox!
    @IBOutlet weak var bootComboBox: NSComboBox!
    @IBOutlet weak var customCodeText: NSTextField!
    @IBOutlet weak var customCodeCheck: NSSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("显示设置窗口...")
        
        indexComboBox.addItem(withObjectValue: "上证指数")
        indexComboBox.addItem(withObjectValue: "深证指数")
        indexComboBox.selectItem(at: Config.getIndexSelect())
        
        bootComboBox.addItem(withObjectValue: "开启")
        bootComboBox.addItem(withObjectValue: "关闭")
        bootComboBox.selectItem(at: Config.getBootSelect())
        
        if Config.getCustomCodeSelect() {
            customCodeCheck?.state = .on
        } else {
            customCodeCheck?.state = .off
        }
        if let value = Config.getCustomCodeText() {
            customCodeText?.stringValue = value
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIndexComboBoxSelectionDidChange(_:)), name: NSComboBox.selectionDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBootComboBoxSelectionDidChange(_:)), name: NSComboBox.selectionDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCustomCodeTextDidChange(_:)), name: NSComboBox.textDidChangeNotification, object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func openSourceUrl(_ sender: NSButton) {
        let url = URL(string: "https://www.google.com")!
        NSWorkspace.shared.open(url)
    }
    @IBAction func customCodeCheck(_ sender: NSSwitch) {
        switch customCodeCheck?.state ?? NSControl.StateValue.off {
        case .on:
        Config.setCustomCodeSelect(value: true)
        case .off:
        Config.setCustomCodeSelect(value: false)
        default:
            print("...")
        }
    }
    
    @objc func handleIndexComboBoxSelectionDidChange(_ notification: Notification) {
        let selectedIndex = indexComboBox.indexOfSelectedItem
        Config.setIndexSelect(value: selectedIndex)
    }
    @objc func handleBootComboBoxSelectionDidChange(_ notification: Notification) {
        let selectedIndex = bootComboBox.indexOfSelectedItem
        Config.setBootSelect(value: selectedIndex)
    }
    @objc func handleCustomCodeTextDidChange(_ notification: Notification) {
        Config.setCustomCodeText(value: customCodeText.stringValue)
    }
        
}
