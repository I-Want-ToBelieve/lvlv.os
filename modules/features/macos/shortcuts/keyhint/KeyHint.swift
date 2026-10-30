// KeyHint: a blurred cheat sheet of the shortcuts that apply to the frontmost app.
//
// `KeyHint --config <file>` runs the agent; `KeyHint toggle` (bound in skhd) asks it to show or
// hide. Bindings come from the JSON that Nix generates; with Accessibility permission the
// frontmost app's menu bar shortcuts are added as well.

import AppKit
import ApplicationServices
import SwiftUI

let toggleNotification = Notification.Name("app.lvlv.keyhint.toggle")

// MARK: - Config

struct ConfigBinding: Decodable {
  let key: String
  let description: String
}

struct ConfigGroup: Decodable {
  let title: String
  let app: String?
  let bindings: [ConfigBinding]
}

struct Config: Decodable {
  var toggleKey: String?
  var groups: [ConfigGroup]

  static func load(_ path: String?) -> Config {
    guard let path, let data = FileManager.default.contents(atPath: path) else {
      return Config(toggleKey: nil, groups: [])
    }
    do {
      return try JSONDecoder().decode(Config.self, from: data)
    } catch {
      NSLog("keyhint: cannot read \(path): \(error)")
      return Config(toggleKey: nil, groups: [])
    }
  }
}

// MARK: - What is shown

struct Row: Identifiable {
  let id = UUID()
  let description: String
  let caps: [String]
}

struct Section: Identifiable {
  let id: String
  let title: String
  var icon: NSImage? = nil
  var symbol: String? = nil
  let rows: [Row]
}

// MARK: - Key names

enum Keys {
  // Apple's order for modifiers in menus.
  static let order = ["fn", "⌃", "⌥", "⇧", "⌘"]

  static let modifiers: [String: [String]] = [
    "cmd": ["⌘"], "lcmd": ["⌘"], "rcmd": ["⌘"],
    "ctrl": ["⌃"], "lctrl": ["⌃"], "rctrl": ["⌃"],
    "alt": ["⌥"], "lalt": ["⌥"], "ralt": ["⌥"],
    "shift": ["⇧"], "lshift": ["⇧"], "rshift": ["⇧"],
    "fn": ["fn"],
    "hyper": ["⌃", "⌥", "⇧", "⌘"],
    "meh": ["⌃", "⌥", "⇧"],
  ]

  // skhd's literal key names.
  static let named: [String: String] = [
    "return": "↩", "tab": "⇥", "space": "Space", "backspace": "⌫", "escape": "esc",
    "delete": "⌦", "home": "↖", "end": "↘", "pageup": "⇞", "pagedown": "⇟",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
  ]

  // Virtual key codes of an ANSI keyboard, as skhd accepts them in hex.
  static let codes: [Int: String] = [
    0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H", 0x05: "G", 0x06: "Z", 0x07: "X",
    0x08: "C", 0x09: "V", 0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R", 0x10: "Y",
    0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=",
    0x19: "9", 0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]", 0x1F: "O", 0x20: "U",
    0x21: "[", 0x22: "I", 0x23: "P", 0x24: "↩", 0x25: "L", 0x26: "J", 0x27: "'", 0x28: "K",
    0x29: ";", 0x2A: "\\", 0x2B: ",", 0x2C: "/", 0x2D: "N", 0x2E: "M", 0x2F: ".", 0x30: "⇥",
    0x31: "Space", 0x32: "`", 0x33: "⌫", 0x35: "esc",
    0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4", 0x60: "F5", 0x61: "F6", 0x62: "F7",
    0x64: "F8", 0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
    0x73: "↖", 0x74: "⇞", 0x75: "⌦", 0x77: "↘", 0x79: "⇟",
    0x7B: "←", 0x7C: "→", 0x7D: "↓", 0x7E: "↑",
  ]

  // Menu glyph codes (kMenu…Glyph) that menu items report for keys without a character.
  static let glyphs: [Int: String] = [
    0x02: "⇥", 0x04: "⌤", 0x09: "Space", 0x0A: "⌦", 0x0B: "↩", 0x17: "⌫", 0x1B: "esc",
    0x1C: "⌧", 0x64: "←", 0x65: "→", 0x68: "↑", 0x6A: "↓",
    0x6F: "F1", 0x70: "F2", 0x71: "F3", 0x72: "F4", 0x73: "F5", 0x74: "F6", 0x75: "F7",
    0x76: "F8", 0x77: "F9", 0x78: "F10", 0x79: "F11", 0x7A: "F12",
  ]

  // Characters AppKit uses for function keys in key equivalents.
  static let functionKeys: [UInt32: String] = [
    0xF700: "↑", 0xF701: "↓", 0xF702: "←", 0xF703: "→",
    0xF704: "F1", 0xF705: "F2", 0xF706: "F3", 0xF707: "F4", 0xF708: "F5", 0xF709: "F6",
    0xF70A: "F7", 0xF70B: "F8", 0xF70C: "F9", 0xF70D: "F10", 0xF70E: "F11", 0xF70F: "F12",
    0xF728: "⌦", 0xF729: "↖", 0xF72B: "↘", 0xF72C: "⇞", 0xF72D: "⇟",
    0x7F: "⌫", 0x08: "⌫", 0x0D: "↩", 0x03: "⌤", 0x09: "⇥", 0x1B: "esc", 0x20: "Space",
  ]

  static func sorted(_ mods: [String]) -> [String] {
    order.filter(mods.contains)
  }

  /// `ctrl + shift - k` → ["⌃", "⇧", "K"]
  static func caps(skhd: String) -> [String] {
    let text = skhd.trimmingCharacters(in: .whitespaces)
    guard let dash = text.range(of: " - ", options: .backwards) else {
      return [key(text)]
    }
    let mods = text[..<dash.lowerBound].split(separator: "+").flatMap { part -> [String] in
      let name = part.trimmingCharacters(in: .whitespaces).lowercased()
      return modifiers[name] ?? [name]
    }
    return sorted(mods) + [key(String(text[dash.upperBound...]))]
  }

  static func key(_ raw: String) -> String {
    let name = raw.trimmingCharacters(in: .whitespaces)
    if name.lowercased().hasPrefix("0x"), let code = Int(name.dropFirst(2), radix: 16) {
      return codes[code] ?? name
    }
    return named[name.lowercased()] ?? name.uppercased()
  }

  static func caps(menuChar: String?, glyph: Int?, modifiers mask: Int) -> [String]? {
    let key: String
    if let char = menuChar, let scalar = char.unicodeScalars.first {
      key = functionKeys[scalar.value] ?? char.uppercased()
    } else if let glyph, let name = glyphs[glyph] {
      key = name
    } else {
      return nil
    }
    // kAXMenuItemModifier…: shift 1, option 2, control 4, and 8 for "no command".
    var mods: [String] = []
    if mask & 4 != 0 { mods.append("⌃") }
    if mask & 2 != 0 { mods.append("⌥") }
    if mask & 1 != 0 { mods.append("⇧") }
    if mask & 8 == 0 { mods.append("⌘") }
    return mods + [key]
  }
}

// MARK: - Menu bar

enum MenuReader {
  static func element(_ parent: AXUIElement, _ name: String) -> AXUIElement? {
    guard let value = copy(parent, name), CFGetTypeID(value) == AXUIElementGetTypeID() else {
      return nil
    }
    return (value as! AXUIElement)
  }

  static func children(_ parent: AXUIElement) -> [AXUIElement] {
    copy(parent, kAXChildrenAttribute) as? [AXUIElement] ?? []
  }

  static func copy(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
      return nil
    }
    return value
  }

  static func sections(pid: pid_t) -> [Section] {
    let app = AXUIElementCreateApplication(pid)
    // A hung app must not hang the overlay.
    AXUIElementSetMessagingTimeout(app, 1)
    guard let bar = element(app, kAXMenuBarAttribute) else { return [] }

    // The first item is the Apple menu, which is the same in every app.
    return children(bar).dropFirst().compactMap { top in
      let title = copy(top, kAXTitleAttribute) as? String ?? ""
      guard !title.isEmpty, let menu = children(top).first else { return nil }
      var rows: [Row] = []
      collect(menu, prefix: nil, depth: 0, into: &rows)
      guard !rows.isEmpty else { return nil }
      return Section(id: "menu/\(title)", title: title, symbol: "filemenu.and.selection", rows: rows)
    }
  }

  static func collect(_ menu: AXUIElement, prefix: String?, depth: Int, into rows: inout [Row]) {
    var seen = Set<String>()
    for item in children(menu) {
      guard let title = copy(item, kAXTitleAttribute) as? String, !title.isEmpty else { continue }
      let name = prefix.map { "\($0) › \(title)" } ?? title
      if let submenu = children(item).first {
        if depth < 2 { collect(submenu, prefix: name, depth: depth + 1, into: &rows) }
        continue
      }
      let char = copy(item, kAXMenuItemCmdCharAttribute) as? String
      let glyph = copy(item, kAXMenuItemCmdGlyphAttribute) as? Int
      let mask = copy(item, kAXMenuItemCmdModifiersAttribute) as? Int ?? 0
      let usable = (char?.isEmpty == false) ? char : nil
      guard let caps = Keys.caps(menuChar: usable, glyph: glyph == 0 ? nil : glyph, modifiers: mask)
      else { continue }
      // Alternate items (shown while holding ⌥) repeat the title; keep the first.
      guard seen.insert(name + caps.joined()).inserted else { continue }
      rows.append(Row(description: name, caps: caps))
    }
  }
}

// MARK: - Model

enum MenuStatus { case loading, ready, untrusted }

final class HintModel: ObservableObject {
  @Published var appName = ""
  @Published var appIcon: NSImage?
  @Published var configured: [Section] = []
  @Published var menu: [Section] = []
  @Published var menuStatus = MenuStatus.loading
  @Published var query = ""
  @Published var bodyHeight: CGFloat = 0
  var toggleCaps: [String] = []

  static let columnWidth: CGFloat = 290
  static let gutter: CGFloat = 28
  static let padding: CGFloat = 22

  var all: [Section] { configured + menu }

  var columns: Int {
    let rows = all.reduce(0) { $0 + $1.rows.count }
    return max(1, min(3, all.count, rows / 6 + 1))
  }

  var width: CGFloat {
    let n = CGFloat(columns)
    return n * Self.columnWidth + (n - 1) * Self.gutter + 2 * Self.padding
  }

  var visible: [Section] {
    let needle = query.trimmingCharacters(in: .whitespaces)
    guard !needle.isEmpty else { return all }
    return all.compactMap { section in
      if section.title.localizedCaseInsensitiveContains(needle) { return section }
      let rows = section.rows.filter {
        $0.description.localizedCaseInsensitiveContains(needle)
          || $0.caps.joined().localizedCaseInsensitiveContains(needle)
      }
      return rows.isEmpty
        ? nil : Section(id: section.id, title: section.title, icon: section.icon, symbol: section.symbol, rows: rows)
    }
  }

  var count: Int { all.reduce(0) { $0 + $1.rows.count } }
}

// MARK: - Views

struct KeyCaps: View {
  let caps: [String]

  var body: some View {
    HStack(spacing: 3) {
      ForEach(Array(caps.enumerated()), id: \.offset) { _, cap in
        Text(cap)
          .font(.system(size: 11.5, weight: .medium, design: .rounded))
          .foregroundStyle(Color.primary.opacity(0.85))
          .padding(.horizontal, 5)
          .frame(minWidth: 21, minHeight: 21)
          .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
              .fill(Color.primary.opacity(0.07))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
              .strokeBorder(Color.primary.opacity(0.10), lineWidth: 0.5)
          )
      }
    }
    .fixedSize()
  }
}

struct SectionView: View {
  let section: Section

  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      HStack(spacing: 6) {
        if let icon = section.icon {
          Image(nsImage: icon).resizable().frame(width: 14, height: 14)
        } else if let symbol = section.symbol {
          Image(systemName: symbol).font(.system(size: 10, weight: .semibold))
        }
        Text(section.title).font(.system(size: 11, weight: .semibold))
      }
      .foregroundStyle(.secondary)
      .padding(.bottom, 2)

      ForEach(section.rows) { row in
        HStack(alignment: .center, spacing: 12) {
          Text(row.description)
            .font(.system(size: 13))
            .lineLimit(1)
            .truncationMode(.middle)
          Spacer(minLength: 0)
          KeyCaps(caps: row.caps)
        }
      }
    }
  }
}

struct SectionsGrid: View {
  let sections: [Section]
  let columns: Int

  // Each section goes to the shortest column so far, which keeps the columns even.
  var split: [[Section]] {
    var result = Array(repeating: [Section](), count: columns)
    var heights = Array(repeating: 0, count: columns)
    for section in sections {
      let shortest = heights.indices.min { heights[$0] < heights[$1] }!
      result[shortest].append(section)
      heights[shortest] += section.rows.count + 2
    }
    return result
  }

  var body: some View {
    HStack(alignment: .top, spacing: HintModel.gutter) {
      ForEach(Array(split.enumerated()), id: \.offset) { _, column in
        VStack(alignment: .leading, spacing: 22) {
          ForEach(column) { SectionView(section: $0) }
        }
        .frame(width: HintModel.columnWidth, alignment: .topLeading)
      }
    }
  }
}

struct HintView: View {
  @ObservedObject var model: HintModel
  var openAccessibility: () -> Void
  @FocusState private var searching: Bool

  var body: some View {
    VStack(spacing: 0) {
      header
      Divider().opacity(0.6)
      content
      Divider().opacity(0.6)
      footer
    }
    .frame(width: model.width)
    .fixedSize()
    .overlay(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .strokeBorder(Color.white.opacity(0.14), lineWidth: 0.5)
    )
    .onAppear { DispatchQueue.main.async { searching = true } }
  }

  var header: some View {
    HStack(spacing: 12) {
      if let icon = model.appIcon {
        Image(nsImage: icon).resizable().frame(width: 38, height: 38)
      }
      VStack(alignment: .leading, spacing: 1) {
        Text(model.appName).font(.system(size: 17, weight: .semibold))
        Text("\(model.count) 个快捷键").font(.system(size: 12)).foregroundStyle(.secondary)
      }
      Spacer(minLength: 16)
      HStack(spacing: 6) {
        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
        TextField("筛选", text: $model.query)
          .textFieldStyle(.plain)
          .focused($searching)
      }
      .font(.system(size: 13))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .frame(width: 210)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.primary.opacity(0.07))
      )
    }
    .padding(.horizontal, HintModel.padding)
    .padding(.top, 18)
    .padding(.bottom, 14)
  }

  @ViewBuilder var content: some View {
    let sections = model.visible
    ScrollView(.vertical, showsIndicators: false) {
      if sections.isEmpty {
        Text(model.all.isEmpty ? "这个应用没有可显示的快捷键" : "没有匹配的快捷键")
          .font(.system(size: 13))
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 28)
      } else {
        SectionsGrid(sections: sections, columns: model.columns)
          .padding(HintModel.padding)
      }
    }
    .frame(height: model.bodyHeight)
  }

  var footer: some View {
    HStack(spacing: 8) {
      switch model.menuStatus {
      case .loading:
        ProgressView().controlSize(.small).scaleEffect(0.7).frame(width: 14, height: 14)
        Text("正在读取菜单栏…")
      case .untrusted:
        Button("授予辅助功能权限后可显示菜单栏快捷键", action: openAccessibility)
          .buttonStyle(.link)
      case .ready:
        EmptyView()
      }
      Spacer()
      if !model.toggleCaps.isEmpty {
        KeyCaps(caps: model.toggleCaps)
        Text("显示 / 隐藏").padding(.trailing, 8)
      }
      KeyCaps(caps: ["esc"])
      Text("关闭")
    }
    .font(.system(size: 11.5))
    .foregroundStyle(.secondary)
    .padding(.horizontal, HintModel.padding)
    .padding(.vertical, 10)
  }
}

// MARK: - Window

final class HintPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
}

@MainActor
final class Controller: NSObject, NSApplicationDelegate, NSWindowDelegate {
  let configPath: String?
  let model = HintModel()
  var panel: HintPanel!
  var hosting: NSHostingView<HintView>!
  var generation = 0
  var anchorTop: CGFloat = 0
  var maxBody: CGFloat = 600

  init(configPath: String?) {
    self.configPath = configPath
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    let panel = HintPanel(
      contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false)
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.level = .floating
    panel.hidesOnDeactivate = false
    panel.isMovableByWindowBackground = false
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    panel.delegate = self

    let blur = NSVisualEffectView()
    blur.material = .hudWindow
    blur.blendingMode = .behindWindow
    blur.state = .active
    blur.wantsLayer = true
    blur.layer?.cornerRadius = 18
    blur.layer?.cornerCurve = .continuous
    blur.layer?.masksToBounds = true

    hosting = NSHostingView(rootView: HintView(model: model) { [weak self] in self?.openAccessibility() })
    hosting.autoresizingMask = [.width, .height]
    blur.addSubview(hosting)
    panel.contentView = blur
    self.panel = panel

    DistributedNotificationCenter.default().addObserver(
      self, selector: #selector(toggle), name: toggleNotification, object: nil,
      suspensionBehavior: .deliverImmediately)

    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard event.keyCode == 53 else { return event }
      self?.hide()
      return nil
    }
  }

  @objc func toggle() {
    panel.isVisible ? hide() : show()
  }

  func show() {
    guard let app = NSWorkspace.shared.frontmostApplication else { return }
    let config = Config.load(configPath)
    let names = [app.localizedName, app.bundleIdentifier, app.executableURL?.lastPathComponent]
      .compactMap { $0?.lowercased() }

    let icon = app.icon
    let own = config.groups.filter { $0.app.map { names.contains($0.lowercased()) } ?? false }
    let global = config.groups.filter { $0.app == nil }
    model.configured =
      own.map { section($0, icon: icon, symbol: nil) }
      + global.map { section($0, icon: nil, symbol: "globe") }
    model.menu = []
    model.query = ""
    model.appName = app.localizedName ?? "当前应用"
    model.appIcon = icon
    model.toggleCaps = config.toggleKey.map(Keys.caps(skhd:)) ?? []

    generation += 1
    let current = generation
    if AXIsProcessTrusted() {
      model.menuStatus = .loading
      let pid = app.processIdentifier
      DispatchQueue.global(qos: .userInitiated).async {
        let menu = MenuReader.sections(pid: pid)
        DispatchQueue.main.async {
          guard current == self.generation else { return }
          self.model.menu = menu
          self.model.menuStatus = .ready
          self.relayout()
        }
      }
    } else {
      model.menuStatus = .untrusted
    }

    let mouse = NSEvent.mouseLocation
    let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main!
    let visible = screen.visibleFrame
    anchorTop = visible.maxY - visible.height * 0.12
    maxBody = visible.height * 0.76 - 130

    // A fresh root view so that onAppear focuses the search field again.
    hosting.rootView = HintView(model: model) { [weak self] in self?.openAccessibility() }
    relayout(center: visible.midX)
    panel.alphaValue = 0
    panel.makeKeyAndOrderFront(nil)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.14
      panel.animator().alphaValue = 1
    }
  }

  func section(_ group: ConfigGroup, icon: NSImage?, symbol: String?) -> Section {
    Section(
      id: "config/\(group.app ?? "*")/\(group.title)", title: group.title, icon: icon, symbol: symbol,
      rows: group.bindings.map { Row(description: $0.description, caps: Keys.caps(skhd: $0.key)) })
  }

  /// Sizes the panel to its content, keeping the top edge where it is.
  func relayout(center: CGFloat? = nil) {
    let grid = NSHostingView(rootView: SectionsGrid(sections: model.all, columns: model.columns))
    let content = model.all.isEmpty ? 80 : grid.fittingSize.height + 2 * HintModel.padding
    model.bodyHeight = min(content, maxBody)

    DispatchQueue.main.async { [self] in
      hosting.layoutSubtreeIfNeeded()
      let size = hosting.fittingSize
      let midX = center ?? panel.frame.midX
      let frame = NSRect(
        x: (midX - size.width / 2).rounded(), y: (anchorTop - size.height).rounded(),
        width: size.width, height: size.height)
      panel.setFrame(frame, display: true, animate: panel.isVisible && center == nil)
      panel.invalidateShadow()
    }
  }

  func hide() {
    guard panel.isVisible else { return }
    generation += 1
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.1
      panel.animator().alphaValue = 0
    } completionHandler: { [weak self] in
      self?.panel.orderOut(nil)
    }
  }

  func openAccessibility() {
    let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    AXIsProcessTrustedWithOptions([prompt: true] as CFDictionary)
  }

  func windowDidResignKey(_ notification: Notification) {
    hide()
  }
}

// MARK: - Entry point

@main
enum Main {
  static func main() {
    let args = CommandLine.arguments
    if args.count > 1, args[1] == "toggle" {
      DistributedNotificationCenter.default().postNotificationName(
        toggleNotification, object: nil, userInfo: nil, deliverImmediately: true)
      return
    }

    var configPath: String?
    if let flag = args.firstIndex(of: "--config"), flag + 1 < args.count {
      configPath = args[flag + 1]
    }

    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let controller = MainActor.assumeIsolated { Controller(configPath: configPath) }
    app.delegate = controller
    withExtendedLifetime(controller) { app.run() }
  }
}
