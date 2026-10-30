{
  flake.modules.homeManager.git = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.bfg-repo-cleaner
      pkgs.colordiff
      pkgs.gh
      pkgs.gist
      pkgs.git-absorb
      pkgs.git-filter-repo
      pkgs.git-machete
      pkgs.git-open
    ];

    programs.git = {
      enable = true;
      lfs.enable = true;
      ignores = ["*~" "*.swp" "*result*" ".direnv" "node_modules"];
      settings = {
        user = {
          name = "yuzhiyong";
          email = "yuzhiyong@zhaojiafang.com";
        };
        init.defaultBranch = "main";
        diff = {
          colorMoved = "default";
          algorithm = "histogram";
        };
        # diff3 without the lines both sides already agree on.
        merge.conflictstyle = "zdiff3";
        # The first push of a new branch sets its upstream.
        push.autoSetupRemote = true;
        fetch.prune = true;
        rebase = {
          autoStash = true;
          # Moves `fixup!` commits (git absorb makes them) next to their targets.
          autoSquash = true;
        };
        # Remember how a conflict was resolved and resolve it the same way next time.
        rerere.enabled = true;
        branch.sort = "-committerdate";
        # The diff under the message being written.
        commit.verbose = true;
        alias = {
          a = "add -p";
          c = "commit";
          co = "checkout";
          cob = "checkout -b";
          f = "fetch -p";
          p = "push";
          r = "restore";
          rs = "restore --staged";
          st = "status -sb";
          ba = "branch -a";
          bd = "branch -d";
          # Alias names are case-insensitive, so this one cannot be called bD next to bd.
          bdf = "branch -D";
          # Delete the branches merged into the current one.
          bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
          d = "diff";
          dc = "diff --cached";
          ds = "diff --staged";
          soft = "reset --soft";
          hard = "reset --hard";
          s1ft = "soft HEAD~1";
          h1rd = "hard HEAD~1";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
          tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
          hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
          llog = ''log --graph --name-status --pretty=format:"%C(red)%h %Creset(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
          rank = "shortlog -sn --no-merges";
          # Pick a commit from `git hist` and show what it changed.
          df = "!git hist | ${lib.getExe pkgs.fzf} | awk '{print $2}' | xargs -I {} git diff {}^ {}";
          edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; \${EDITOR:-nvim} $(f)";
        };
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        # bat's base16 theme draws with the terminal's 16 colours, which stylix sets.
        syntax-theme = "base16";
        line-numbers = true;
        # Moved lines keep their syntax colours over the theme's highlight backgrounds.
        map-styles = lib.mkIf (config.lib ? stylix) (
          with config.lib.stylix.colors.withHashtag; "bold purple => syntax ${base03}, bold cyan => syntax ${base02}"
        );
      };
    };
  };
}
