{ inputs, lib, config, pkgs, ... }:

let
  palette = (import ./palettes.nix)."gruvbox";
in

{
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true); # ISSUE: https://github.com/nix-community/home-manager/issues/2942
    };
  };

  home = {
    stateVersion = "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    username = "philopence";
    homeDirectory = "/home/philopence";
    pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    sessionPath = [
      "$XDG_DATA_HOME/npm/bin"
    ];
    packages = with pkgs; [
      gnumake
      gcc
      unzip
      zip
      xclip
      brightnessctl
      trashy
      chafa
      fishPlugins.z
      fishPlugins.done
      nodejs
      nodePackages.npm
      nodePackages.prettier
      nodePackages.volar
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript-language-server
      lua-language-server
      ripgrep
      fd
      bat
      fzf
      jq
      html-tidy
      stylua
      httpie
      ranger
      btop
      lazygit
      scrot
      keepassxc
      pcmanfm
      papirus-icon-theme
    ];
  };

  gtk = {
    enable = true;
    font.name = "monospace";
    iconTheme = {
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.materia-theme;
      name = "Materia-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = "kvantum";
    style.package = with pkgs; [
      materia-kde-theme
      qtstyleplugin-kvantum-qt4
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
    ];
  };

  xsession = { enable = true; };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    dataFile = {
      "fcitx5/rime/default.custom.yaml".text = ''
        patch:
          ascii_composer:
            switch_key:
              Shift_L: noop
              Shift_R: noop
              # Shift_L: commit_code
              # Shift_R: commit_text
          key_binder:
            bindings:
              - {accept: Left, send: Page_Up, when: has_menu}
              - {accept: Right, send: Page_Down, when: has_menu}
              # - {accept: "Release+Escape", toggle: ascii_mode, when: always}
      '';
      "fcitx5/rime/luna_pinyin.custom.yaml".text = ''
        patch:
          "switches/@0/reset": 0
          "recognizer/patterns/reverse_lookup":
          "translator/dictionary": extended
          "punctuator/half_shape/=":
            "'": {pair: ["「", "」"]}
            '"': {pair: ["『", "』"]}
      '';
      "fcitx5/rime/extended.dict.yaml".text = ''
        ---
        name: extended
        version: "0.0.1"
        sort: by_weight
        use_preset_vocabulary: true
        import_tables:
          - luna_pinyin
          - zhwiki
          - moegirl
        ...
      '';
    };

  };

  xdg.configFile = {
    "bspwm/bspwmrc".source = pkgs.writeShellScript "bspwmrc" ''
      # pgrep -x sxhkd > /dev/null || sxhkd &
      bspc monitor -d 1 2 3 4 5
      bspc config border_width         2
      bspc config window_gap           5
      bspc config top_padding          0
      bspc config bottom_padding       0
      bspc config left_padding         0
      bspc config right_padding        0
      bspc config normal_border_color  "${palette."5"}"
      bspc config focused_border_color "${palette."B"}"
      bspc config split_ratio          0.50
      bspc config borderless_monocle   true
      bspc config gapless_monocle      true
      bspc rule -a kitty desktop='^1'
      bspc rule -a Chromium-browser desktop='^2'
      bspc rule -a SystemInfo state=floating center=on
      bspc desktop "^2" --layout monocle
    '';
    "sxhkd/sxhkdrc".text = ''
      super + p
        kitty --class "SystemInfo" btop
      super + Escape
        pkill -USR1 -x sxhkd
      super + {_,shift + }Return
        {kitty, rofi -show drun}
      super + {comma,period,slash}
        amixer sset Master {3%-,3%+,toggle}
      super + shift + {comma,period}
        brightnessctl set 3%{-,+}
      super + w
        bspc node focused --close
      super + {t,shift + t,f,shift + f}
        bspc node --state {tiled,pseudo_tiled,floating,fullscreen}
      super + {j,k}
        bspc node focused --focus {next,prev}.leaf.local.!hidden
      super + shift + {j,k}
        bspc node focused --swap {next,prev}.leaf.local.!hidden
      super + {h,l}
        bspc desktop focused --focus {prev,next}.local
      super + shift + {h,l}
        bspc node focused --to-desktop {prev,next}.local --follow
      super + {_,shift + }{1-5}
        bspc {desktop -f,node -d} '^{1-5}'
      super + alt + {h,j,k,l}
        bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}
      super + ctrl + {h,j,k,l}
        bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}
    '';
  };

  services.syncthing.enable = true;

  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size = "32x32";
    };
    settings = {
      global = {
        offset = "15x15";
        frame_color = palette."B";
        font = "monospace 10";

      };
      urgency_low = {
        background = palette."1";
        foreground = palette."7";
        timeout = 3;
      };

      urgency_normal = {
        background = palette."1";
        foreground = palette."7";
        timeout = 5;
      };
      urgency_critical = {
        background = palette."1";
        foreground = palette."7";
        timeout = 0;
      };
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeSteps = [ 0.05 0.05 ];
    shadow = true;
    # shadowOffsets = [ (-10) (-10) ];
    settings = {
      shadow-radius = 15;
      blur = {
        # method = "gaussian";
        # size = 10;
        # deviation = 5.0;
        method = "dual_kawase";
        strength = "10";
      };
    };
  };

  programs.kitty = {
    enable = true;
    environment = {
      "THEME" = palette."name";
    };
    # font = {
    #   name = "Rec Mono Linear";
    #   # name = "mononoki";
    #   size = 11;
    # };
    settings = {
      # font_family = "Rec Mono Casual";
      # bold_font = "Rec Mono Casual Bold";
      # italic_font = "Rec Mono Casual Italic";
      # bold_italic_font = "Rec Mono Casual Bold Italic";
      font_family = "Cascadia Code Regular";
      bold_font = "Cascadia Code Bold";
      italic_font = "Cascadia Code Italic";
      bold_italic_font = "Cascadia Code Bold Italic";
      font_size = "10";
      background_opacity = "0.9";
      cursor_shape = "beam";
      #
      foreground = palette."7";
      background = palette."1";
      selection_foreground = palette."7";
      selection_background = palette."4";
      cursor = palette."A";
      cursor_text_color = palette."1";
      url_color = palette."C";
      active_border_color = palette."B";
      inactive_border_color = palette."B";
      bell_border_color = palette."F";
      visual_bell_color = "none";
      active_tab_foreground = palette."1";
      active_tab_background = palette."B";
      inactive_tab_foreground = palette."5";
      inactive_tab_background = palette."2";
      tab_bar_background = "none";
      tab_bar_margin_color = "none";
      mark1_foreground = palette."1";
      mark1_background = palette."D";
      mark2_foreground = palette."1";
      mark2_background = palette."E";
      mark3_foreground = palette."1";
      mark3_background = palette."F";
      color0 = palette."0";
      color8 = palette."2";
      color1 = palette."8";
      color9 = palette."8";
      color2 = palette."9";
      color10 = palette."9";
      color3 = palette."A";
      color11 = palette."A";
      color4 = palette."B";
      color12 = palette."B";
      color5 = palette."C";
      color13 = palette."C";
      color6 = palette."D";
      color14 = palette."D";
      color7 = palette."E";
      color15 = palette."E";
      color16 = palette."F";
      color17 = palette."F";
      # "modify_font baseline" = -1;
      "modify_font cell_height" = 1;
      "font_features CascadiaCode-Regular" = "+zero";
      "font_features CascadiaCode-Bold" = "+zero";
      "font_features CascadiaCode-Italic" = "+zero";
      "font_features CascadiaCode-BoldItalic" = "+zero";
      "symbol_map" = "U+E000-U+E00D,U+e0a0-U+e0a2,U+e0b0-U+e0b3,U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4,U+e5fa-U+e62b,U+e700-U+e7c5,U+f000-U+f2e0,U+e200-U+e2a9,U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c,U+F300-U+F32F,U+23fb-U+23fe,U+2b58-U+2b58,U+f0001-U+f0010,U+e300-U+e3eb Symbols Nerd Font Mono";
    };
    keybindings = {
      "kitty_mod+enter" = "launch --type window --cwd=current";
      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+j" = "next_window";
      "kitty_mod+k" = "previous_window";
      "kitty_mod+h" = "previous_tab";
      "kitty_mod+l" = "next_tab";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  programs.git = {
    enable = true;
    userName = "philopence";
    userEmail = "epcroo@yeah.net";
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
    };
  };

  programs.rofi = {
    enable = true;
    # font = "Rec Mono Casual 12";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "";
      drun-display-format = "{name}";
      drun-match-fields = "name";
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          text-color = mkLiteral palette."7";
          background-color = mkLiteral palette."1";
          border-color = mkLiteral palette."B";
        };
        "window" = {
          font = "mono 12";
          # width = 512;
        };
        "#inputbar" = {
          children = map mkLiteral [ "prompt" "entry" ];
        };
        "#prompt" = {
          font = "mono 24";
          padding = mkLiteral "0.5em 2em";
          text-color = mkLiteral palette."1";
          background-color = mkLiteral palette."B";
          vertical-align = mkLiteral "0.5";
        };
        "#entry" = {
          padding = mkLiteral "0 1em";
          vertical-align = mkLiteral "0.5";
        };
        "#listview" = {
          lines = mkLiteral "7";
          columns = mkLiteral "2";
          padding = mkLiteral "1em 0";
        };
        "#element" = {
          padding = mkLiteral "0.2em 1em";
          spacing = mkLiteral "0.5em";
        };
        "#element selected" = {
          text-color = mkLiteral palette."B";
          text-transform = mkLiteral "bold";
        };
        "#element-icon" = {
          size = mkLiteral "32";
          vertical-align = mkLiteral "0.5";
        };
        "#element-text" = {
          text-color = mkLiteral "inherit";
          # background-color = mkLiteral "inherit";
          text-transform = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
        };
      };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "aapbdbdomjkkjkaonfhkkikfgjllcleb"; } # google translate
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "nhdogjmejiglipccpnnnanhbledajbpd"; } # vue.js devtools
    ];
  };

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      fish_prompt = ''
        echo -n (set_color red)"["
        echo -n (set_color yellow)"$USER"
        echo -n (set_color green)"@"
        echo -n (set_color blue)(prompt_hostname)" "
        set_color -o
        echo -n (set_color magenta)(prompt_pwd)
        set_color normal
        echo -n (set_color red)"]"
        if fish_is_root_user
          echo -n (set_color cyan)"#"" "
        else
          echo -n (set_color cyan)"\$"" "
        end
        set_color normal
      '';
    };
  };


  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    prefix = "C-Space";
    extraConfig = ''
      DATE="%a %b %d %H:%M %p"
      PREFIX="#{?client_prefix,#[fg=red],#[fg=white]}"
      CWD="#{?client_prefix,#[bg=red],#[bg=white]}#[fg=black#,bold]  #(basename #{pane_current_path}) #[default]"
      WINDOW="#[fg=white] #I #F #W #[default]"
      CURRENT_WINDOW="#[fg=blue#,bold#,italics] #I #F #W #[default]"
      SESSION="#[fg=black#,bg=white#,bold] #S #[default]"
      set -g status-interval 1
      set -g status-position bottom
      set -g status-style "default"
      set -g status-left-length 50
      set -g status-left "$CWD "
      set -g status-right "$DATE $SESSION"
      ##
      set -g window-status-format "$WINDOW"
      set -g window-status-current-format "$CURRENT_WINDOW"
      # set -g window-status-separator " "
      ##
      set -g pane-border-style "fg=white"
      set -g pane-active-border-style "fg=blue"
      ##
      set -g message-style "fg=yellow"
      set -g message-command-style "fg=red"
      ##
      set -g default-terminal "tmux-256color"
      set -sa terminal-features ',XXX:RGB'
      set -g renumber-windows on
      set -g mode-keys vi
      bind : command-prompt -p "COMMAND:"
      bind -n M-j select-pane -t ":.{next}"
      bind -n M-k select-pane -t ":.{previous}"
      bind -n M-h previous-window
      bind -n M-l next-window
      bind x split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind r command-prompt -I "#W" "rename-window '%%'"
      bind c command-prompt "new-window -c '#{pane_current_path}' -n '%%'"
      bind q kill-pane
      bind Q kill-window
      bind -r H swap-window -d -t ":{previous}"
      bind -r L swap-window -d -t ":{next}"
      bind -r M-h resize-pane -L 2
      bind -r M-j resize-pane -D 2
      bind -r M-k resize-pane -U 2
      bind -r M-l resize-pane -R 2
    '';
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
