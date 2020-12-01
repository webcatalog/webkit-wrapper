import AppKit
import WebKit

struct AppConfig: Decodable {
  let id: String!
  let name: String!
  let url: URL!
}

let defaultAppJsonContent = """
{
  "id": "example",
  "name": "Example",
  "url": "https://example.com"
}
""".data(using: .utf8)!
let decoder = JSONDecoder()
var jsonData = try decoder.decode(AppConfig.self, from: defaultAppJsonContent)

// AppName.app/Contents/Resources/app.asar.unpacked/build/app.json
if let appJsonPath = Bundle.main.url(forResource: "app.asar.unpacked/build/app", withExtension: "json")  {
  do {
    let data = try Data(contentsOf: appJsonPath, options: .mappedIfSafe)
    let decoder = JSONDecoder()
    jsonData = try decoder.decode(AppConfig.self, from: data)
  } catch {}
} else {}

// https://medium.com/@theboi/macos-apps-without-storyboard-or-xib-menu-bar-in-swift-5-menubar-and-toolbar-6f6f2fa39ccb
extension NSMenuItem {
  convenience init(title string: String, target: AnyObject = self as AnyObject, action selector: Selector?, keyEquivalent charCode: String, modifier: NSEvent.ModifierFlags = .command) {
    self.init(title: string, action: selector, keyEquivalent: charCode)
    keyEquivalentModifierMask = modifier
    self.target = target
  }
  convenience init(title string: String, submenuItems: [NSMenuItem]) {
    self.init(title: string, action: nil, keyEquivalent: "")
    self.submenu = NSMenu()
    self.submenu?.items = submenuItems
  }
}

extension WKWebView {
  @objc func copyUrl(_: Any? = nil) {
    if let url = self.url {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(url.absoluteString, forType: .string)
    } else {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(jsonData.url!.absoluteString, forType: .string)
    }
  }

  @objc func goHome(_: Any? = nil) {
    self.load(URLRequest(url: jsonData.url!))
  }
}

class WindowDelegate: NSObject, NSWindowDelegate {
  func windowWillClose(_ notification: Notification) {
    NSApplication.shared.terminate(0)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  let window = NSWindow()
  let windowDelegate = WindowDelegate()

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Disable tabbing mode introduced in macOS 10.12
    if #available(macOS 10.12, *) {
      NSWindow.allowsAutomaticWindowTabbing = false
    }

    // Application Menu
    // https://medium.com/@theboi/macos-apps-without-storyboard-or-xib-menu-bar-in-swift-5-menubar-and-toolbar-6f6f2fa39ccb
    let mainMenu = NSMenu()
    
    let appMenu = NSMenuItem()
    appMenu.submenu = NSMenu()
    appMenu.submenu?.items = [
      NSMenuItem(title: "Hide \(jsonData.name!)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
      NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    ]
    mainMenu.addItem(appMenu)

    let editItem = NSMenuItem()
    editItem.submenu = NSMenu(title: "Edit")
    editItem.submenu?.items = [
      NSMenuItem(title: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z"),
      NSMenuItem(title: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z"),
      NSMenuItem.separator(),
      NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
      NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
      NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),
      NSMenuItem(title: "Delete", target: self, action: nil, keyEquivalent: "⌫", modifier: .init()),
      NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
    ]
    mainMenu.addItem(editItem)

    let viewMenu = NSMenuItem()
    viewMenu.submenu = NSMenu(title: "View")
    viewMenu.submenu?.items = [
      NSMenuItem(title: "Reload This Page", action: #selector(WKWebView.reload(_:)), keyEquivalent: "r")
    ]
    mainMenu.addItem(viewMenu)

    let historyMenu = NSMenuItem()
    historyMenu.submenu = NSMenu(title: "History")
    historyMenu.submenu?.items = [
      NSMenuItem(title: "Home", action: #selector(WKWebView.goHome(_:)), keyEquivalent: "h"),
      NSMenuItem(title: "Back", action: #selector(WKWebView.goBack(_:)), keyEquivalent: "["),
      NSMenuItem(title: "Forward", action: #selector(WKWebView.goForward(_:)), keyEquivalent: "]"),
      NSMenuItem.separator(),
      NSMenuItem(title: "Copy URL", action: #selector(WKWebView.copyUrl(_:)), keyEquivalent: "l")
    ]
    mainMenu.addItem(historyMenu)

    let windowMenu = NSMenuItem()
    windowMenu.submenu = NSMenu(title: "Window")
    windowMenu.submenu?.items = [
      NSMenuItem(title: "Minimize", action: #selector(NSApplication.miniaturizeAll(_:)), keyEquivalent: "m")
    ]
    mainMenu.addItem(windowMenu)

    NSApplication.shared.mainMenu = mainMenu
    
    // Windows
    let size = CGSize(width: 800, height: 768)
    window.setContentSize(size)
    window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
    window.delegate = windowDelegate
    window.title = jsonData.name

    window.center()
    window.makeKeyAndOrderFront(window)
    
    // WebView
    let webView = WKWebView(frame: window.frame)
    webView.allowsBackForwardNavigationGestures = true
    window.contentView = webView
    // use custom user agent to improve website compatibility
    if #available(macOS 10.11, *) {
      webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15"
    }
    webView.load(URLRequest(url: jsonData.url!))
  
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()