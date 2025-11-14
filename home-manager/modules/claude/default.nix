{
  lib,
  config,
  pkgs,
  inputs ? {},
  ...
}:
let
  cfg = config.homelab.tools.claude;
  hasNixpak = inputs ? nixpak;
  mkNixPak = if hasNixpak then inputs.nixpak.lib.nixpak {
    inherit pkgs lib;
  } else null;


  claude-sandbox = if hasNixpak then mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.claude-code;
      
      dbus.enable = true;
      dbus.policies = {
        "org.freedesktop.DBus" = "talk";
      };
      
      bubblewrap = {
        network = true;
        
        bind.rw = [
          (sloth.concat' sloth.homeDir "/.claude")
          "/tmp"
        ];
        
        bind.ro = [
          (sloth.concat' sloth.homeDir "/.ssh")
          (sloth.concat' sloth.homeDir "/.gitconfig")
          "/etc/ssl"
          "/etc/ca-certificates"
        ];
        
        # extraArgs = [
        #   "--setenv" "TERM" "xterm-256color"
        # ];
      };
    };
  } else null;
in
{
  options.homelab.tools.claude = {
    enable = lib.mkEnableOption "Enable Claude Code IDE with nixpak sandboxing";
  };

  config = lib.mkIf (cfg.enable && hasNixpak) {
    home.packages = with pkgs; [
      claude-sandbox.config.env
    ];
  };
}
