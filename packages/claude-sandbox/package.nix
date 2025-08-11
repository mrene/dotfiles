{ lib, pkgs, config, inputs, ... }: 

let 
  mkNixPak = inputs.nixpak.lib.nixpak { 
    inherit pkgs lib;
  };


  claude-sandbox = mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.claude-code;
      app.binPath = "bin/claude";
      
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
        
        # bind.ro = [
        #   (sloth.concat' sloth.homeDir "/.gitconfig")
        # ];
      };
    };
  };
in

claude-sandbox.config.env