{ inputs, ... }:
{
  flake.modules.nixos.utm =
    {
      lib,
      pkgs,
      common,
      inputs,
      self,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nixos-lima.nixosModules.lima
        # disk-default removed - using hardware-configuration.nix instead
        inputs.nixos-lima.nixosModules.impure-config
        inputs.nixos-lima.nixosModules.lima-container
      ];

      lima.settings = {
        ssh.localPort = 2222;
        memory = "16GB";
        cpus = 8;
        disk = "128GB";
      };

      lima.user = {
        name = "mrene";
        sshPubKey = lib.mkForce "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4=";
      };

      documentation.enable = false;

      # Enable refactored homelab modules
      homelab.vm-common.enable = true;
      homelab.ssh-ca.enable = true;
      homelab.common-packages.enable = true;
      homelab.fonts.enable = true;
      homelab.minikube.enable = true;
      homelab.vm.common.enable = true;
      homelab.vscode-server.enable = true;
      environment.systemPackages = [ pkgs.nix-output-monitor ];

      users.users.root.openssh.authorizedKeys.keys = common.builderKeys ++ common.sudoSshKeys;
      users.users.mrene.openssh.authorizedKeys.keys =
        common.builderKeys ++ common.sudoSshKeys ++ common.sshKeys;

      networking.hostName = "utm";
      networking.firewall.enable = false;

      services.tailscale.enable = true;

      home-manager = {
        users.mrene = {
          imports = [
            self.modules.homeManager.all
            self.modules.homeManager.utm
          ];
        };
        useGlobalPkgs = true;
        verbose = true;
        extraSpecialArgs = { inherit inputs self; };
      };

      system.stateVersion = "22.05";
    };
}
