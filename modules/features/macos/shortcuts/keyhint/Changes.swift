// The panel `activate` opens after a switch: what `nix store diff-closures` reports between the
// previous and the new system, grouped into added, removed and changed packages.

import AppKit
import SwiftUI

// MARK: - Diff

struct Change: Identifiable {
  /// `config` is a file such as hm_…zshrc or etc: no version, so not worth a row of its own.
  enum Kind { case added, removed, changed, size, config }

  let id = UUID()
  let name: String
  let kind: Kind
  let from: String
  let to: String
  /// Change in closure size, in KiB.
  let size: Double
}

enum ClosureDiff {
  static let ansi = try! NSRegularExpression(pattern: "\u{1B}\\[[0-9;]*m")
  static let sizePattern = try! NSRegularExpression(pattern: "^[+-][0-9.]+ [KMGT]iB$")

  /// Parses lines such as `bat: 0.26.0, 0.26.0-fish → 0.26.1, 0.26.1-fish, -486.3 KiB`,
  /// `ICU: ∅ → 76.1, +40951.6 KiB` and `aria2: -28.4 KiB`.
  static func parse(_ text: String) -> [Change] {
    text.split(separator: "\n").compactMap { raw in
      let line = ansi.stringByReplacingMatches(
        in: String(raw), range: NSRange(raw.startIndex..., in: raw), withTemplate: "")
      guard let colon = line.range(of: ": ") else { return nil }
      let name = String(line[..<colon.lowerBound])
      let rest = String(line[colon.upperBound...])

      guard let arrow = rest.range(of: " → ") else {
        return Change(name: name, kind: .size, from: "", to: "", size: kib(rest) ?? 0)
      }
      var right = rest[arrow.upperBound...].components(separatedBy: ", ")
      var size = 0.0
      if let last = right.last, let value = kib(last) {
        size = value
        right.removeLast()
      }
      let left = rest[..<arrow.lowerBound].components(separatedBy: ", ")
      let from = versions(left)
      let to = versions(right)
      let versioned = (left + right).contains { $0.first?.isNumber == true }
      let kind: Change.Kind =
        !versioned ? .config : left == ["∅"] ? .added : right == ["∅"] ? .removed : .changed
      return Change(name: name, kind: kind, from: from, to: to, size: size)
    }
  }

  static func kib(_ text: String) -> Double? {
    let text = text.trimmingCharacters(in: .whitespaces)
    guard sizePattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    else { return nil }
    let parts = text.split(separator: " ")
    let scales: [String: Double] = ["KiB": 1, "MiB": 1024, "GiB": 1_048_576, "TiB": 1_073_741_824]
    let scale = scales[String(parts[1])]!
    return Double(parts[0])! * scale
  }

  /// `0.26.1, 0.26.1-fish` → `0.26.1`: variants that only add a suffix to a version say nothing new.
  static func versions(_ list: [String]) -> String {
    let named = list.filter { $0 != "∅" }.map { $0 == "ε" ? "—" : $0 }
    let kept = named.filter { version in
      !named.contains { $0 != version && version.hasPrefix($0 + "-") }
    }
    return kept.joined(separator: ", ")
  }

  static func format(_ kib: Double, signed: Bool = true) -> String {
    let magnitude = abs(kib)
    let (value, unit): (Double, String) =
      magnitude >= 1024 * 1024 ? (magnitude / 1024 / 1024, "GiB")
      : magnitude >= 1024 ? (magnitude / 1024, "MiB") : (magnitude, "KiB")
    let sign = signed ? (kib < 0 ? "−" : "+") : ""
    return "\(sign)\(String(format: value >= 100 ? "%.0f" : "%.1f", value)) \(unit)"
  }
}

// MARK: - System generations

struct SystemInfo {
  let generation: Int?
  let nixpkgs: String?

  /// The profile link (system-N-link) that points at `path`, and the nixpkgs it was built from.
  init(_ path: String) {
    let profiles = "/nix/var/nix/profiles"
    let fm = FileManager.default
    let links = (try? fm.contentsOfDirectory(atPath: profiles)) ?? []
    generation = links.compactMap { link -> Int? in
      guard link.hasPrefix("system-"), link.hasSuffix("-link"),
        let target = try? fm.destinationOfSymbolicLink(atPath: "\(profiles)/\(link)"),
        target == path
      else { return nil }
      return Int(link.dropFirst("system-".count).dropLast("-link".count))
    }.max()

    let json = fm.contents(atPath: "\(path)/darwin-version.json")
      .flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
    nixpkgs = (json?["nixpkgsRevision"] as? String).map { String($0.prefix(7)) }
  }
}

// MARK: - Model

final class ChangesModel: ObservableObject {
  @Published var query = ""
  @Published var bodyHeight: CGFloat = 0
  var changes: [Change] = []
  var subtitle = ""

  static let columnWidth: CGFloat = 300

  /// Two columns at least, so that the header and the stats have room.
  var columns: Int {
    changes.filter { $0.kind != .size && $0.kind != .config }.count <= 16 ? 2 : 3
  }

  func of(_ kind: Change.Kind) -> [Change] { changes.filter { $0.kind == kind } }
  var total: Double { changes.reduce(0) { $0 + $1.size } }

  var sections: [ChangeSection] {
    let needle = query.trimmingCharacters(in: .whitespaces)
    let matching = needle.isEmpty
      ? changes : changes.filter { $0.name.localizedCaseInsensitiveContains(needle) }
    return [
      ChangeSection(kind: .added, title: "新增", symbol: "plus.circle.fill", color: .green),
      ChangeSection(kind: .removed, title: "移除", symbol: "minus.circle.fill", color: .red),
      ChangeSection(kind: .changed, title: "版本变化", symbol: "arrow.triangle.2.circlepath.circle.fill", color: .blue),
    ].compactMap { section in
      var section = section
      section.rows = matching.filter { $0.kind == section.kind }
      return section.rows.isEmpty ? nil : section
    }
  }

  var width: CGFloat {
    let n = CGFloat(columns)
    return n * Self.columnWidth + (n - 1) * HintModel.gutter + 2 * HintModel.padding
  }
}

struct ChangeSection: Identifiable {
  var id: String { "\(title)/\(part)" }
  let kind: Change.Kind
  let title: String
  let symbol: String
  let color: Color
  var rows: [Change] = []
  var part = 0
}

/// Splits the sections into columns of about equal height, in order. A section that does not
/// fit continues at the top of the next column.
func flow(_ sections: [ChangeSection], columns: Int) -> [[ChangeSection]] {
  let total = sections.reduce(0) { $0 + $1.rows.count + 2 }
  let target = max(4, Int((Double(total) / Double(columns)).rounded(.up)))
  var result = [[ChangeSection]](repeating: [], count: columns)
  var column = 0
  var height = 0
  for section in sections {
    var rows = section.rows[...]
    var part = 0
    while !rows.isEmpty {
      let last = column == columns - 1
      var room = last ? rows.count : target - height - 2
      // A section that nearly fits stays whole, and none starts with fewer than three rows.
      if rows.count <= room + 3 {
        room = rows.count
      } else if room < 3 {
        column += 1
        height = 0
        continue
      }
      var piece = section
      piece.rows = Array(rows.prefix(room))
      piece.part = part
      result[column].append(piece)
      height += piece.rows.count + 2
      rows = rows.dropFirst(room)
      part += 1
    }
  }
  return result
}

// MARK: - Views

struct ChangeRow: View {
  let change: Change

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Text(change.name)
        .font(.system(size: 13))
        .lineLimit(1)
        .truncationMode(.middle)
        .layoutPriority(1)
      Spacer(minLength: 0)
      versions
        .font(.system(size: 11.5, design: .monospaced))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .truncationMode(.head)
      Text(change.size == 0 ? "" : ClosureDiff.format(change.size))
        .font(.system(size: 10.5, design: .rounded))
        .foregroundStyle(.tertiary)
        .frame(width: 62, alignment: .trailing)
    }
  }

  @ViewBuilder var versions: some View {
    switch change.kind {
    case .added: Text(change.to)
    case .removed: Text(change.from).strikethrough()
    default: Text("\(change.from) → \(change.to)")
    }
  }
}

struct ChangeSectionView: View {
  let section: ChangeSection

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 6) {
        Image(systemName: section.symbol).foregroundStyle(section.color)
        Text(section.part == 0 ? section.title : "\(section.title)（续）")
          .foregroundStyle(.secondary)
      }
      .font(.system(size: 11, weight: .semibold))
      .padding(.bottom, 2)
      ForEach(section.rows) { ChangeRow(change: $0) }
    }
  }
}

struct ChangesGrid: View {
  let sections: [ChangeSection]
  let columns: Int

  var body: some View {
    HStack(alignment: .top, spacing: HintModel.gutter) {
      ForEach(Array(flow(sections, columns: columns).enumerated()), id: \.offset) {
        _, column in
        VStack(alignment: .leading, spacing: 20) {
          ForEach(column) { ChangeSectionView(section: $0) }
        }
        .frame(width: ChangesModel.columnWidth, alignment: .topLeading)
      }
    }
  }
}

struct Stat: View {
  let value: String
  let label: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundStyle(color)
        .monospacedDigit()
      Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.primary.opacity(0.05))
    )
  }
}

struct ChangesView: View {
  @ObservedObject var model: ChangesModel
  @FocusState private var searching: Bool

  var body: some View {
    VStack(spacing: 0) {
      header
      stats
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
      Image(systemName: "shippingbox.fill")
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 38, height: 38)
        .background(
          RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(LinearGradient(
              colors: [Color(red: 0.36, green: 0.55, blue: 0.98), Color(red: 0.25, green: 0.36, blue: 0.86)],
              startPoint: .top, endPoint: .bottom))
        )
      VStack(alignment: .leading, spacing: 1) {
        Text("系统已更新").font(.system(size: 17, weight: .semibold))
        Text(model.subtitle).font(.system(size: 12)).foregroundStyle(.secondary)
      }
      Spacer(minLength: 16)
      HStack(spacing: 6) {
        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
        TextField("筛选软件包", text: $model.query)
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

  var stats: some View {
    HStack(spacing: 10) {
      Stat(value: "\(model.of(.added).count)", label: "新增", color: .green)
      Stat(value: "\(model.of(.removed).count)", label: "移除", color: .red)
      Stat(value: "\(model.of(.changed).count)", label: "版本变化", color: .blue)
      Stat(value: ClosureDiff.format(model.total), label: "闭包体积", color: .primary)
    }
    .padding(.horizontal, HintModel.padding)
    .padding(.bottom, 16)
  }

  @ViewBuilder var content: some View {
    let sections = model.sections
    ScrollView(.vertical, showsIndicators: false) {
      if sections.isEmpty {
        Text(model.changes.isEmpty ? "软件包没有变化，只有配置更新" : "没有匹配的软件包")
          .font(.system(size: 13))
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 28)
      } else {
        ChangesGrid(sections: sections, columns: model.columns).padding(HintModel.padding)
      }
    }
    .frame(height: model.bodyHeight)
  }

  var footer: some View {
    HStack(spacing: 8) {
      let others = [
        (model.of(.size).count, "个软件包只有体积变化"),
        (model.of(.config).count, "个配置文件有变化"),
      ].filter { $0.0 > 0 }.map { "\($0.0) \($0.1)" }
      if !others.isEmpty {
        Text("另有 " + others.joined(separator: "，"))
      }
      Spacer()
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

@MainActor
final class ChangesController: NSObject, NSApplicationDelegate, NSWindowDelegate {
  let model = ChangesModel()
  var panel: HintPanel!

  /// Called from `main`, which runs on the main thread.
  nonisolated static func run(old: String, new: String, diffFile: String) {
    let text = (try? String(contentsOfFile: diffFile, encoding: .utf8)) ?? ""
    try? FileManager.default.removeItem(atPath: diffFile)

    MainActor.assumeIsolated {
      let app = NSApplication.shared
      app.setActivationPolicy(.accessory)
      let controller = ChangesController()
      controller.model.changes = ClosureDiff.parse(text).sorted {
        $0.name.localizedStandardCompare($1.name) == .orderedAscending
      }
      controller.model.subtitle = subtitle(old: SystemInfo(old), new: SystemInfo(new))
      app.delegate = controller
      withExtendedLifetime(controller) { app.run() }
    }
  }

  static func subtitle(old: SystemInfo, new: SystemInfo) -> String {
    var parts: [String] = []
    switch (old.generation, new.generation) {
    case let (a?, b?): parts.append("第 \(a) 代 → 第 \(b) 代")
    case let (nil, b?): parts.append("第 \(b) 代")
    default: break
    }
    if let a = old.nixpkgs, let b = new.nixpkgs {
      parts.append(a == b ? "nixpkgs \(b)" : "nixpkgs \(a) → \(b)")
    }
    parts.append(Date().formatted(date: .omitted, time: .shortened))
    return parts.joined(separator: " · ")
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    let (panel, blur) = makeOverlay(delegate: self)
    self.panel = panel

    let mouse = NSEvent.mouseLocation
    let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main!
    let visible = screen.visibleFrame

    let grid = NSHostingView(rootView: ChangesGrid(sections: model.sections, columns: model.columns))
    let content = model.sections.isEmpty ? 80 : grid.fittingSize.height + 2 * HintModel.padding
    model.bodyHeight = min(content, visible.height * 0.76 - 200)

    let hosting = NSHostingView(rootView: ChangesView(model: model))
    hosting.autoresizingMask = [.width, .height]
    blur.addSubview(hosting)
    let size = hosting.fittingSize
    let top = visible.maxY - visible.height * 0.12
    panel.setFrame(
      NSRect(
        x: (visible.midX - size.width / 2).rounded(), y: (top - size.height).rounded(),
        width: size.width, height: size.height),
      display: true)

    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard event.keyCode == 53 else { return event }
      self?.close()
      return nil
    }

    // Launched from a terminal, so take focus: Esc and clicking elsewhere then close it.
    NSApp.activate(ignoringOtherApps: true)
    panel.alphaValue = 0
    panel.makeKeyAndOrderFront(nil)
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.18
      panel.animator().alphaValue = 1
    }
  }

  func close() {
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.1
      panel.animator().alphaValue = 0
    } completionHandler: {
      exit(0)
    }
  }

  func windowDidResignKey(_ notification: Notification) {
    close()
  }
}
