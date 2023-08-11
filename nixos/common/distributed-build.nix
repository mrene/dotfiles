{ lib, config, ... }:

{
  # To add a machine, don't forget to add the key to common.nix
  #nix.buildMachines =
    #lib.optionals (config.networking.hostName != "beast") [{
      #hostName = "beast";
      #system = "x86_64-linux";
      #maxJobs = 8;
      #speedFactor = 10;
      #supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      #mandatoryFeatures = [ ];
    #}] ++
    #lib.optionals (config.networking.hostName != "beast") [{
      #hostName = "beast";
      #system = "aarch64-linux";
      #maxJobs = 8;
      #speedFactor = 2; # emulation via qemu
      #supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      #mandatoryFeatures = [ ];
    #}] ++
    #lib.optionals (config.networking.hostName != "utm") [{
      #hostName = "utm";
      #system = "aarch64-linux";
      #maxJobs = 10;
      #speedFactor = 5;
      #supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      #mandatoryFeatures = [ ];
    #}] ++
    #lib.optionals (config.networking.hostName != "nas") [{
      #hostName = "nas";
      #system = "x86_64-linux";
      #maxJobs = 8;
      #speedFactor = 5;
      #supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      #mandatoryFeatures = [ ];
    #}];


  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.settings.substituters = lib.optionals (config.networking.hostName != "nas") [ "http://nas:5000" ] ++
                              lib.optionals (config.networking.hostName != "beast") [ "http://beast:5000" ];

}
