{ lib, pkgs, config, inputs, ... }: 

let 
  mkNixPak = inputs.nixpak.lib.nixpak { 
    inherit pkgs lib;
  };


  claude-sandbox = mkNixPak {
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
  };
in
{
  home.packages = with pkgs; [
    claude-sandbox.config.env
  ];
}
