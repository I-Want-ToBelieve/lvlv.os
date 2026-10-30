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

      keybindings = lib.mkMerge [
        {
          "ctrl+v" = "paste_from_clipboard";
          "ctrl+c" = "copy_or_interrupt";
          "super+c" = "copy_or_interrupt";
          "ctrl+shift+v" = "paste_from_selection";
          "ctrl+shift+c" = "copy_to_clipboard";
          "shift+insert" = "paste_from_selection";
          "ctrl+shift+up" = "scroll_line_up";
          "ctrl+shift+down" = "scroll_line_down";
          "ctrl+shift+k" = "scroll_line_up";
          "ctrl+shift+j" = "scroll_line_down";
          "ctrl+shift+page_up" = "scroll_page_up";
          "ctrl+shift+page_down" = "scroll_page_down";
          "ctrl+shift+home" = "scroll_home";
          "ctrl+shift+end" = "scroll_end";
          "ctrl+shift+h" = "show_scrollback";
          "ctrl+shift+enter" = "new_window";
          "ctrl+shift+n" = "new_os_window";
          "ctrl+shift+w" = "close_window";
          "ctrl+shift+]" = "next_window";
          "ctrl+shift+[" = "previous_window";
          "ctrl+shift+f" = "move_window_forward";
          "ctrl+shift+b" = "move_window_backward";
          "ctrl+shift+`" = "move_window_to_top";
          "ctrl+shift+1" = "first_window";
          "ctrl+shift+2" = "second_window";
          "ctrl+shift+3" = "third_window";
          "ctrl+shift+4" = "fourth_window";
          "ctrl+shift+5" = "fifth_window";
          "ctrl+shift+6" = "sixth_window";
          "ctrl+shift+7" = "seventh_window";
          "ctrl+shift+8" = "eighth_window";
          "ctrl+shift+9" = "ninth_window";
          "ctrl+shift+0" = "tenth_window";
          "ctrl+shift+right" = "next_tab";
          "ctrl+shift+left" = "previous_tab";
          "ctrl+shift+tab" = "previous_tab";
          "ctrl+tab" = "next_tab";
          "mouse_button4" = "next_tab";
          "mouse_button5" = "previous_tab";
          "ctrl+shift+t" = "new_tab";
          "ctrl+shift+q" = "close_tab";
          "ctrl+shift+l" = "next_layout";
          "ctrl+shift+." = "move_tab_forward";
          "ctrl+shift+," = "move_tab_backward";
          "ctrl+shift+alt+t" = "set_tab_title";
          "ctrl+shift+equal" = "increase_font_size";
          "ctrl+shift+minus" = "decrease_font_size";
          "ctrl+shift+backspace" = "restore_font_size";
          # Search the scrollback with fzf and copy the chosen line.
          "ctrl+f" = ''launch --type=overlay --stdin-source=@screen_scrollback sh -c "${lib.getExe pkgs.fzf} --no-sort --no-mouse --exact -i --tac | kitty +kitten clipboard"'';
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "cmd+shift+v" = "paste_from_clipboard";
          "cmd+shift+s" = "paste_from_selection";
          "cmd+shift+c" = "copy_to_clipboard";
          "cmd+shift+up" = "scroll_line_up";
          "cmd+shift+down" = "scroll_line_down";
          "cmd+shift+k" = "scroll_line_up";
          "cmd+shift+j" = "scroll_line_down";
          "cmd+shift+page_up" = "scroll_page_up";
          "cmd+shift+page_down" = "scroll_page_down";
          "cmd+shift+home" = "scroll_home";
          "cmd+shift+end" = "scroll_end";
          "cmd+shift+h" = "show_scrollback";
          "cmd+shift+enter" = "new_window";
          "cmd+shift+n" = "new_os_window";
          "cmd+shift+w" = "close_window";
          "cmd+shift+]" = "next_window";
          "cmd+shift+[" = "previous_window";
          "cmd+shift+f" = "move_window_forward";
          "cmd+shift+b" = "move_window_backward";
          "cmd+shift+`" = "move_window_to_top";
          "cmd+shift+1" = "first_window";
          "cmd+shift+2" = "second_window";
          "cmd+shift+3" = "third_window";
          "cmd+shift+4" = "fourth_window";
          "cmd+shift+5" = "fifth_window";
          "cmd+shift+6" = "sixth_window";
          "cmd+shift+7" = "seventh_window";
          "cmd+shift+8" = "eighth_window";
          "cmd+shift+9" = "ninth_window";
          "cmd+shift+0" = "tenth_window";
          "cmd+shift+right" = "next_tab";
          "cmd+shift+left" = "previous_tab";
          "cmd+shift+t" = "new_tab";
          "cmd+shift+q" = "close_tab";
          "cmd+shift+l" = "next_layout";
          "cmd+shift+." = "move_tab_forward";
          "cmd+shift+," = "move_tab_backward";
          "cmd+shift+alt+t" = "set_tab_title";
          "cmd+shift+equal" = "increase_font_size";
          "cmd+shift+minus" = "decrease_font_size";
          "cmd+shift+backspace" = "restore_font_size";
        })
      ];
    };
  };
}
