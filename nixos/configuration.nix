{ inputs, outputs, lib, config, pkgs, ... }:
let
  wallpaper = builtins.fetchurl {
    url = "https://w.wallhaven.cc/full/8o/wallhaven-8oky1j.jpg";
    sha256 = "07m8gm75ihaxqdwsg43rg5wjx3silqa22zl15lylzqpj35150d72";
  };
  rimeZhwiki = builtins.fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.4/zhwiki-20230728.dict.yaml";
    sha256 = "083n6k9lc5d5f01n3nqnmsshmlzbb1ar3v40n393adiqxl5nrj98";
  };
  rimeMoegirl = builtins.fetchurl {
    url = "https://github.com/outloudvi/mw2fcitx/releases/download/20230714/moegirl.dict.yaml";
    sha256 = "1rfw94yxxgsp0hpfvj84745i7ag7l75wv74hv1id02pi9z4478ab";
  };
in
{
  imports = [
    ./hardware.nix
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      # substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-rime ];
    };
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      cascadia-code
      jetbrains-mono
      recursive
      comic-mono
      mononoki
      fantasque-sans-mono
      sarasa-gothic
    ];
    fontconfig.defaultFonts.sansSerif = [ "Sarasa Mono SC" ];
    fontconfig.defaultFonts.serif = [ "Sarasa Mono SC" ];
    fontconfig.defaultFonts.monospace = [ "Sarasa Mono SC" ];
  };

  sound = {
    enable = true;
    extraConfig = ''
      defaults.pcm.!card 1
      defaults.ctl.!card 1
    '';
  };

  # hardware.pulseaudio.enable = true;
  hardware.opengl.enable = true;

  networking = {
    hostName = "nixos";
    useDHCP = true;
    wireless = {
      enable = true;
      networks = {
        "2333" = {
          hidden = true;
          pskRaw = "0757c284de894a5f99f144ce63711f70b9641b27eb65d2311b851835a87f12b0";
        };
        # "hotspot" = {
        #   pskRaw = "6589d759a80278d2fd8b3d105934f19b877fafe3896e0c4632632dd846635f7e";
        # };
      };
    };
    # networkmanager.enable = true;
    firewall.enable = true;
  };
  services.v2raya.enable = true;
  services.udev.packages = with pkgs; [via vial];
  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  environment = {
    localBinInPath = true;
    variables = {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      NIX_CONFIGURATION = "$HOME/.local/share/nix-configuration";
      GLFW_IM_MODULE = "ibus";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
  };

  users = {
    defaultUserShell = pkgs.fish;
    users = {
      philopence = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$jMsehOPIRelnQkFovjHjZ.$5szH.Lkoev8OcPYot34ODSuEkwAEMQdqdkD8Z/.fCG9";
        extraGroups = [ "wheel" ];
      };
    };
  };

  programs.fish.enable = true;

  programs.npm = {
    enable = true;
    npmrc = ''
      prefix = ''${XDG_DATA_HOME}/npm
      cache = ''${XDG_CACHE_HOME}/npm
      registry = https://registry.npmmirror.com
    '';
  };

  services = {
    xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.gtk.cursorTheme = {
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors";
          size = 24;
        };
      };
      displayManager.sessionCommands = ''
        xset r rate 200 35
        fcitx5 &
        FILES=("$HOME/.background-image" "$XDG_DATA_HOME/fcitx5/rime/zhwiki.dict.yaml" "$XDG_DATA_HOME/fcitx5/rime/moegirl.dict.yaml")
        for FILE in "''${FILES[@]}"; do
          if [ ! -f $FILE ]; then
            install -Dm644 ${wallpaper}
            install -Dm644 ${rimeZhwiki} $XDG_DATA_HOME/fcitx5/rime/zhwiki.dict.yaml
            install -Dm644 ${rimeMoegirl} $XDG_DATA_HOME/fcitx5/rime/moegirl.dict.yaml
          fi
        done
      '';
      windowManager.bspwm.enable = true;
      libinput = {
        touchpad.naturalScrolling = true;
      };
    };
  };

  services.udisks2.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
