{
  flake.modules.homeManager.kitty = {
    lib,
    pkgs,
    ...
  }: {
    programs.kitty = {
      enable = true;
      # Font, colours (tab bar included) and background opacity come from stylix.
      settings = {
        # Tab bar
        tab_bar_style = "fade";
        tab_bar_edge = "bottom";
        tab_title_template = "{index}: {title}";
        bell_on_tab = "yes";
        active_tab_font_style = "bold-italic";
        inactive_tab_font_style = "bold";
        # Window
        inactive_text_alpha = "1.0";
        window_padding_width = "12 24 0 24";
        placement_strategy = "center";
        resize_in_steps = "yes";
        enabled_layouts = "*";
        remember_window_size = "no";
        initial_window_width = "640";
        initial_window_height = "400";
        confirm_os_window_close = "0";
        allow_remote_control = "yes";
        # URLs and selection
        url_style = "double";
        copy_on_select = "yes";
        select_by_word_characters = ":@-./_~?&=%+#";
        # Mouse
        click_interval = "0.5";
        mouse_hide_wait = "0";
        focus_follows_mouse = "no";
        # Bell
        visual_bell_duration = "0.0";
        enable_audio_bell = "no";
        # Scrollback
        scrollback_lines = "10000";
        wheel_scroll_multiplier = "5.0";
        touch_scroll_multiplier = "1.0";
        # Cursor
        cursor_shape = "underline";
        cursor_beam_thickness = "1.2";
        cursor_underline_thickness = "2.0";
        cursor_blink_interval = "-1.0";
        cursor_stop_blinking_after = "5.0";
        # Text
        disable_ligatures = "never";
        box_drawing_scale = "0.001, 1, 1.5, 2";
        # macOS
        macos_show_window_title_in = "none";
        macos_menubar_title_max_length = "0";
        hide_window_decorations = "titlebar-only";
      };

      # The mouse's side buttons switch tabs.
      mouseBindings = {
        "b4 press" = "ungrabbed,grabbed next_tab";
        "b5 press" = "ungrabbed,grabbed previous_tab";
      };

      keybindings = lib.mkMerge [
        # kitty's own ctrl+shift (kitty_mod) bindings already cover scrolling, windows, tabs,
        # layouts and font size; these are the ones that differ.
        {
          "ctrl+v" = "paste_from_clipboard";
          "ctrl+c" = "copy_or_interrupt";
          "super+c" = "copy_or_interrupt";
          "ctrl+shift+v" = "paste_from_selection";
          # Search the scrollback with fzf and copy the chosen line.
          "ctrl+f" = ''launch --type=overlay --stdin-source=@screen_scrollback sh -c "${lib.getExe pkgs.fzf} --no-sort --no-mouse --exact -i --tac | kitty +kitten clipboard"'';
        }
        # The same bindings on cmd+shift, which sits where ctrl+shift does on a Mac keyboard.
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.mapAttrs' (key: lib.nameValuePair "cmd+shift+${key}") {
          v = "paste_from_clipboard";
          s = "paste_from_selection";
          c = "copy_to_clipboard";
          up = "scroll_line_up";
          down = "scroll_line_down";
          k = "scroll_line_up";
          j = "scroll_line_down";
          page_up = "scroll_page_up";
          page_down = "scroll_page_down";
          home = "scroll_home";
          end = "scroll_end";
          h = "show_scrollback";
          enter = "new_window";
          n = "new_os_window";
          w = "close_window";
          "]" = "next_window";
          "[" = "previous_window";
          f = "move_window_forward";
          b = "move_window_backward";
          "`" = "move_window_to_top";
          "1" = "first_window";
          "2" = "second_window";
          "3" = "third_window";
          "4" = "fourth_window";
          "5" = "fifth_window";
          "6" = "sixth_window";
          "7" = "seventh_window";
          "8" = "eighth_window";
          "9" = "ninth_window";
          "0" = "tenth_window";
          right = "next_tab";
          left = "previous_tab";
          t = "new_tab";
          q = "close_tab";
          l = "next_layout";
          "." = "move_tab_forward";
          "," = "move_tab_backward";
          "alt+t" = "set_tab_title";
          equal = "increase_font_size";
          minus = "decrease_font_size";
          backspace = "restore_font_size";
        }))
      ];
    };
  };
}
