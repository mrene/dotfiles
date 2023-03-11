{ lib, config, ... }:

{
  nix.buildMachines =
    lib.optionals (config.networking.hostName != "beast") [{
      hostName = "beast";
      system = "x86_64-linux";
      maxJobs = 8;
      speedFactor = 10;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }] ++
    lib.optionals (config.networking.hostName != "beast") [{
      hostName = "beast";
      system = "aarch64-linux";
      maxJobs = 8;
      speedFactor = 2; # emulation via qemu
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }] ++ 
    lib.optionals (config.networking.hostName != "utm") [{
      hostName = "utm";
      system = "aarch64-linux";
      maxJobs = 10;
      speedFactor = 5;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];

    nix.distributedBuilds = true;
  	nix.settings.builders-use-substitutes = true;
}
