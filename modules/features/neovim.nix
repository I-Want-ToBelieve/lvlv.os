# Neovim configured in Nix with nixvim: plugins and language servers are pinned by flake.lock
# and stylix gives it the colour scheme. Neovim's own defaults already map K (hover),
# grn (rename), gra (code action), grr (references) and [d / ]d (diagnostics).
{inputs, ...}: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    imports = [inputs.nixvim.homeModules.nixvim];

    programs.nixvim = {
      enable = true;
      # The nixpkgs the host is built from (unstable, or 26.05 on Intel Macs); set here
      # because nixvim warns when its input's follows changes the default without being stated.
      nixpkgs.source = pkgs.path;
      # The host's own package set, with its nixpkgs.config, instead of a second instance.
      nixpkgs.useGlobalPackages = true;
      # $EDITOR, also run as vi and vim.
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # No plugin here needs a Ruby or Python host.
      withRuby = false;
      withPython3 = false;

      globals.mapleader = " ";
      opts = {
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        cursorline = true;
        scrolloff = 8;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        ignorecase = true;
        smartcase = true;
        undofile = true;
        # Yank and paste through the system clipboard.
        clipboard = "unnamedplus";
      };

      keymaps = [
        {
          key = "gd";
          action.__raw = "vim.lsp.buf.definition";
          options.desc = "Go to definition";
        }
        {
          key = "<leader>e";
          action = "<cmd>Oil<cr>";
          options.desc = "Edit the directory of this file";
        }
      ];

      plugins = {
        web-devicons.enable = true;
        lualine.enable = true;
        # Shows what the keys after <leader> do while they are typed.
        which-key.enable = true;
        gitsigns.enable = true;
        # Directories as editable buffers.
        oil.enable = true;
        treesitter = {
          enable = true;
          # The languages in use here, not all few hundred grammars.
          grammarPackages = let
            g = pkgs.vimPlugins.nvim-treesitter.builtGrammars;
          in [
            g.bash
            g.c
            g.css
            g.diff
            g.dockerfile
            g.fish
            g.gitcommit
            g.html
            g.javascript
            g.json
            g.lua
            g.markdown
            g.markdown_inline
            g.nix
            g.python
            g.query
            g.regex
            g.rust
            g.toml
            g.tsx
            g.typescript
            g.vim
            g.vimdoc
            g.yaml
          ];
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options.desc = "Find files";
            };
            "<leader>fg" = {
              action = "live_grep";
              options.desc = "Search the project";
            };
            "<leader>fb" = {
              action = "buffers";
              options.desc = "Buffers";
            };
            "<leader>fd" = {
              action = "diagnostics";
              options.desc = "Diagnostics";
            };
          };
        };
        blink-cmp.enable = true;
        lsp = {
          enable = true;
          servers = {
            nil_ls = {
              enable = true;
              settings.formatting.command = ["alejandra"];
            };
            # cargo and rustc come from the dev-tools feature or the project's devShell.
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            ts_ls.enable = true;
            basedpyright.enable = true;
            bashls.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
          };
        };
        # Formats on save through the language server, or the formatters listed here.
        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              lsp_format = "fallback";
              timeout_ms = 1000;
            };
            formatters_by_ft = {
              nix = ["alejandra"];
              rust = ["rustfmt"];
            };
          };
        };
      };
    };
  };
}
