//
//  AppDelegate.swift
//  cvr
//
//  Created by 小洋粉 on 2021/12/21.
//

import Cocoa
import HotKey
import LaunchAtLogin
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    internal var hotKeys: [String: HotKey] = [
        "C+b" : HotKey(key: .b, modifiers: [.command]),
        "C+g" : HotKey(key: .g, modifiers: [.command])
    ]
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let itemImage = NSImage(named: "S")
        itemImage?.isTemplate = true
        statusItem.button?.image = itemImage
        initHotKeys()
        constructMenu()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

extension AppDelegate {
    func constructMenu() {
      let menu = NSMenu()
        let str = LaunchAtLogin.isEnabled ? "✔" : "✗"
      menu.addItem(NSMenuItem(title:str + "  开机启动" , action: #selector(AppDelegate.startLogin(_:)), keyEquivalent: "s"))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

      statusItem.menu = menu
        
    }
    @objc func startLogin(_ sender: Any?) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        constructMenu()
    }
}


extension AppDelegate  {
    func initHotKeys(){
        hotKeys["C+b"]?.keyDownHandler = { [self] in
            commandCStr() { str in
                let appStoreURL =  "https://www.baidu.com/s?ie=UTF-8&wd=\(str)"
                    .addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
                NSWorkspace.shared.open(URL(string: appStoreURL ?? "https://www.baidu.com")!)
            }
        }
        hotKeys["C+g"]?.keyDownHandler = { [self] in
            commandCStr() { str in
                let appStoreURL =  "https://www.google.com/search?q=\(str)"
                    .addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
                NSWorkspace.shared.open(URL(string: appStoreURL ?? "https://www.goolge.com")!)
            }
        }
    }
}

extension AppDelegate {
    // 模拟command+c 并获取剪切板内容
    internal func commandCStr(_ perform: @escaping (_ str: String) -> ())  {
        // 模拟command+c按键
        analogButton(flags: [.maskCommand],key: 0x08)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            perform(NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) ?? "")
        }
    }

}



// 模拟按键
func analogButton(flags:CGEventFlags,key:CGKeyCode) {
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    let spcd = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
    spcd?.flags = flags
    spcd?.post(tap: CGEventTapLocation.cghidEventTap)
}
