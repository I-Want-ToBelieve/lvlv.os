{
  flake.modules.darwin.zsh = {
    # An /etc/zshrc that loads the nix-darwin environment; zsh is macOS' default shell.
    programs.zsh.enable = true;
  };

  flake.modules.homeManager.zsh = {
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    fzf = lib.getExe pkgs.fzf;
    plugin = name: src: file: {inherit name src file;};
  in {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;

      history = {
        size = 10000;
        save = 10000;
        append = true;
        extended = true;
        ignoreAllDups = true;
        saveNoDups = true;
        expireDuplicatesFirst = true;
      };
      setOptions = [
        "ALWAYS_TO_END"
        "AUTO_CD"
        "AUTO_LIST"
        "AUTO_MENU"
        "AUTO_PARAM_SLASH"
        "AUTO_PUSHD"
        "COMPLETE_IN_WORD"
        "CORRECT"
        "HIST_FCNTL_LOCK"
        "HIST_REDUCE_BLANKS"
        "HIST_VERIFY"
        "INTERACTIVE_COMMENTS"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"
        "PUSHD_TO_HOME"
        "NO_CORRECT_ALL"
        "NO_HIST_BEEP"
        "NO_MENU_COMPLETE"
        "NO_NOMATCH"
      ];

      # `cd ~download` and friends.
      dirHashes = {
        documents = "$HOME/Documents";
        dotfiles = "$HOME/dotfiles";
        download = "$HOME/Downloads";
        music = "$HOME/Music";
        pictures = "$HOME/Pictures";
        videos =
          if isDarwin
          then "$HOME/Movies"
          else "$HOME/Videos";
        media =
          if isDarwin
          then "/Volumes"
          else "/run/media/$USER";
      };

      completionInit = ''
        autoload -U compinit && compinit -i
        _comp_options+=(globdots)
      '';

      initContent = lib.mkMerge [
        ''
          export SUDO_PROMPT=$'Password for ->\033[32;05;16m %u\033[0m  '

          zmodload zsh/zle
          zmodload zsh/zpty
          zmodload zsh/complist
          autoload -Uz colors && colors

          # Completion: grouped and described matches, case-insensitive and then partial-word
          # matching, one typo forgiven.
          zstyle ':completion:*' sort false
          zstyle ':completion:complete:*:options' sort false
          zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*' rehash true
          zstyle ':completion:*' menu yes select
          zstyle ':completion:*' list-grouped false
          zstyle ':completion:*' list-separator '''
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*' verbose yes
          zstyle ':completion:*:matches' group 'yes'
          zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
          zstyle ':completion:*:messages' format '%d'
          zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
          zstyle ':completion:*:descriptions' format '[%d]'
          zstyle ':completion:*' completer _complete _match _approximate
          zstyle ':completion:*:match:*' original only
          zstyle ':completion:*:approximate:*' max-errors 1 numeric
          zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
          zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
          zstyle ':completion:*:jobs' numbers true
          zstyle ':completion:*:jobs' verbose true
          zstyle ':completion:*:git-checkout:*' sort false
          zstyle ':completion:*' file-sort modification
          zstyle ':completion:*:eza' sort false
          zstyle ':completion:files' sort false

          ZSH_AUTOSUGGEST_USE_ASYNC=true

          function run() {
            nix run nixpkgs#$@
          }

          function nix-search() {
            nix search "''${@:-nixpkgs}" ".*" |
              grep "^\* " | sed "s/^\* //;s/ (.*//" |
              sed -r "s/\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?m//g" |
              ${fzf} --preview="nix search nixpkgs '^{}$'"
          }

          function extract() {
            if [ -z "$1" ]; then
              echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso>"
              echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
              return 1
            fi
            for n in "$@"; do
              if [ ! -f "$n" ]; then
                echo "'$n' - file doesn't exist"
                return 1
              fi
              case "''${n%,}" in
                *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) tar xvf "$n" ;;
                *.lzma) unlzma ./"$n" ;;
                *.bz2) bunzip2 ./"$n" ;;
                *.cbr|*.rar) unrar x -ad ./"$n" ;;
                *.gz) gunzip ./"$n" ;;
                *.cbz|*.epub|*.zip) unzip ./"$n" ;;
                *.z) uncompress ./"$n" ;;
                *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar) 7z x ./"$n" ;;
                *.xz) unxz ./"$n" ;;
                *.exe) cabextract ./"$n" ;;
                *.cpio) cpio -id < ./"$n" ;;
                *.cba|*.ace) unace x ./"$n" ;;
                *.zpaq) zpaq x ./"$n" ;;
                *.arc) arc e ./"$n" ;;
                *.cso) ciso 0 ./"$n" ./"$n.iso" && extract "$n.iso" && \rm -f "$n" ;;
                *.zlib) zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && mv ./"$n.tmp" ./"''${n%.*zlib}" && rm -f "$n" ;;
                *)
                  echo "extract: '$n' - unknown archive method"
                  return 1
                  ;;
              esac
            done
          }

          # Show the directory stack in the terminal title.
          precmd() {
            printf '\033]0;%s\007' "$(dirs)"
          }
        ''
        # Completion colours from LS_COLORS, which vivid exports earlier in .zshrc.
        (lib.mkAfter "zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}")
      ];

      shellAliases = {
        cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
        bloat = "nix path-info -Sh /run/current-system";
        ytmp3 = ''${lib.getExe pkgs.yt-dlp} -x --audio-format mp3 --audio-quality 0 --embed-metadata --embed-thumbnail --parse-metadata "title:%(artist)s - %(title)s" -o "%(title)s.%(ext)s"'';
        cat = "${lib.getExe pkgs.bat} --style=plain";
        grep = lib.getExe pkgs.ripgrep;
        du = lib.getExe pkgs.dust;
        ps = lib.getExe pkgs.procs;
        rm = "${pkgs.trash-cli}/bin/trash-put";
        m = "mkdir -p";
        fcd = ''cd "$(find . -type d | ${fzf})"'';
        http = "${lib.getExe pkgs.python3} -m http.server";
        ssh = "kitty +kitten ssh";
      };

      plugins = [
        (plugin "zsh-nix-shell" pkgs.zsh-nix-shell "share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh")
        (plugin "zsh-vi-mode" pkgs.zsh-vi-mode "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh")
        (plugin "fast-syntax-highlighting" pkgs.zsh-fast-syntax-highlighting "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh")
        (plugin "zsh-autopair" pkgs.zsh-autopair "share/zsh/zsh-autopair/autopair.zsh")
      ];
    };
  };
}
