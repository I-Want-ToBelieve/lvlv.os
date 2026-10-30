# lvlv.os

NixOS 和 nix-darwin 主机配置，基于 flake-parts、dendritic 模式和 import-tree。

| 主机 | 平台 | 内容 |
| --- | --- | --- |
| `k99-lite` | x86_64-linux | 最小 NixOS：能启动、联网、通过 SSH 管理，不带桌面和应用 |
| `k99-lite-darwin` | aarch64-darwin | 完整的 macOS 工作站 |
| `k99lite-darwin-x64` | x86_64-darwin | k99-lite 经 OpenCore 引导的 macOS：同样的工作站配置，nixpkgs 停在 26.05 |

切换本机：

```bash
nix run .#activate
```

Feature / Profile / Host 契约、目录结构和常用命令见 [AGENTS.md](AGENTS.md)。
