# lvlv.os 约定

写给在这个仓库里工作的人和编码智能体。架构是 flake-parts + dendritic + import-tree，依赖由 `flake.lock` 固定。

## 目录

`modules/` 下的每个 `.nix` 文件都是 flake-parts 模块，由 import-tree 自动导入。路径里带 `/_` 的文件除外（例如 `_hardware.nix`）：它们是普通的 NixOS / nix-darwin 模块，由主机文件按路径引用。

| 目录 | 内容 |
| --- | --- |
| `modules/flake/` | flake 层：systems、契约（`contract.nix`）、devShell、formatter、`activate` |
| `modules/features/` | Feature |
| `modules/profiles/` | Profile |
| `modules/users/` | 账号，也是 Feature |
| `modules/hosts/` | Host |

## 契约

**Feature**：`flake.modules.<class>.<name>`，class 是 `nixos`、`darwin` 或 `homeManager`。

- 一个文件可以给同一个 feature 定义多个 class，例如 `fish` 同时有 darwin 部分和 homeManager 部分。
- 不引用任何主机。
- 需要外部模块时在 feature 里 `imports`，`inputs` 从外层 flake-parts 模块的参数取，不用 `specialArgs`。
- 不导入别的 feature，组合由 Profile 负责。
- 主机可能要改的值用 `lib.mkDefault`。

**Profile**：`lvlv.profiles.<class>.<name>`，同一个 class 的 feature 名字列表。

**Host**：`lvlv.hosts.<name>`，是唯一组装系统的地方。`modules/flake/contract.nix` 由它生成 `nixosConfigurations` / `darwinConfigurations` 和每台主机的 check。

- 字段：`class`、`system`、`stateVersion`、`profiles`、`features`、`modules`、`home.<user>`。
- `stateVersion` 是首次安装时的版本，永远不改。
- `hostName` 默认取主机名。
- 主机上的 feature 如果还有 homeManager 部分，会自动加给这台主机的每个 Home Manager 用户。只属于某个用户的 feature 写在 `home.<user>.profiles` / `features` 里。

Feature、Profile 和 `system` 的名字都是 enum。写错名字时求值会直接报错，并列出可用的名字。

## 命令

| 做什么 | 命令 |
| --- | --- |
| 两个平台全部求值，不构建 | `nix flake check --all-systems --no-build` |
| 构建本平台的主机并检查格式和 lint | `nix flake check` |
| 格式化，并应用 statix / deadnix 的修复 | `nix fmt` |
| 切换本机 | `nix run .#activate` |
| 切换本机，先显示包的变化 | `nh darwin switch .` / `nh os switch .` |
| 从这台 Mac 经 SSH 部署 k99-lite（在目标机上构建） | `nix run .#activate -- k99-lite --target-host root@<地址> --build-host root@<地址>` |
| 更新依赖 | `nix flake update`，然后跑上面的检查；CI 每周也会开一个更新 `flake.lock` 的 PR |

`.github/workflows/check.yml` 在每次 push 和 PR 时，于 Linux 和 macOS 上各自求值本平台的主机并检查格式。

## 主机

- `k99-lite-darwin` 和 `k99-lite` 是同一台机器（GRUB 引导 NixOS，或经 OpenCore 引导 macOS）。两边的用户都用 `cli` home profile，命令行环境一致；只有 macOS 有 `desktop`。
- 密钥用 sops-nix（`secrets` feature，在 `minimal` profile 里），主机用自己的 SSH host key 解密。加第一个密钥的步骤写在 `modules/features/secrets.nix` 的注释里，所需命令在 devShell 中。

## AI 知识：nix-skills

进入 devShell 时（`direnv allow` 或 `nix develop`），`lvlv.agentSkills` 里选中的技能会链接到 `.claude/skills` 和 `.agents/skills`。这两个目录已写进 `.gitignore`，技能版本跟着 `flake.lock` 走。

改 Nix 代码之前，先加载对应的技能：

- 语言本身：`nix-language`
- 命令与排错：`nix-workflow`
- NixOS 运维：`nixos-operations`、`nixos-wiki`
- macOS：`nix-darwin`
- 用户配置：`home-manager`
- 打包：`nixpkgs-development`

## 写法

- 优先用上游提供的选项，不靠 `mkForce` 互相覆盖。确实需要覆盖时，在旁边写明原因。
- 不用已弃用的选项。`nix flake check` 的输出里不应出现 evaluation warning。
- 包用 `pkgs.<name>` 逐个列出，不写 `with pkgs;`。
- 注释写为什么这样做，不复述代码做了什么。
