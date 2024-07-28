
{ lib, config, pkgs, inputs, flakePackages, ... }: 


let
  cfg = config.services.openthread-border-router;
in 
{
  options.services.openthread-border-router = {
    enable = lib.mkEnableOption "Enable the OpenThread Border Router";

    package = lib.mkOption {
      type = lib.types.package ;
      default = pkgs.callPackage ../../../packages/openthread-border-router/package.nix {};
      description = "The openthread-border-router package";
    };

    radioDevice = lib.mkOption {
      type = lib.types.str;
      #default = "/dev/ttyACM0";
      default = "/dev/ttyUSB0";
      description = "The device name of the serial port of the radio device";
    };

    backboneInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "The network interface on which to advertise the thread ipv6 range";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "wpan0";
      description = "The network interface on which to advertise the thread ipv6 range";
    };

    logLevel = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = ''
      The logging level to use:
        EMERG 0
        ALERT 1
        CRIT 2
        ERR 3
        WARNING 4
        NOTICE 5
        INFO 6
        DEBUG 7
      '';
    };

    #baudRate = lib.mkOption {
      #type = lib.types.int;
      #default = 460800;
      #description = "The baud rate of the radio device";
    #};

    #flowControl = lib.mkOption {
      #type = lib.types.bool;
      #default = true;
      #description = "Enable hardware flow control";
    #};

    radioUrl = lib.mkOption {
      type = lib.types.str;
      # TODO: Split URL components into individual options
      default = "spinel+hdlc+uart:///dev/ttyUSB0?uart-baudrate=460800&uart-flow-control";
      description = "The URL of the radio device";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    boot.kernel.sysctl = {
      # Make sure we have ipv6 support, and that forwarding is enabled
      "net.ipv6.conf.all.disable_ipv6" = 0;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv6.ip_forward" = 1;

      # Make sure we accept IPv6 router advertisements from the local network interface
      "net.ipv6.conf.${cfg.backboneInterface}.accept_ra" = 2;
      "net.ipv6.conf.${cfg.backboneInterface}.accept_ra_rt_info_max_plen" = 64;
    };

    # OTBR needs to publish its addresses via avahi
    services.avahi.enable = lib.mkDefault true;
    services.avahi.publish.enable = lib.mkDefault true;
    services.avahi.publish.userServices = lib.mkDefault true;

    # Synchronize the services with the unit files defined in the source pacakge
    systemd.services = {

      # TODO: Where is this defined?
      # Probably not required since avahi is being used
      #mdns = {};

      # src/agent/otbr-agent.service.in
      # The agent keeps its local state in /var/lib/thread
      otbr-agent = {
        description = "OpenThread Border Router Agent";
        wantedBy = [ "multi-user.target" ];
        requires =  [ "dbus.socket" ];
        after = [ "dbus.socket" ];
        serviceConfig = {
          ExecStart = "${lib.getExe' cfg.package "otbr-agent"} -v -B ${cfg.backboneInterface} -I ${cfg.interfaceName} -d ${toString cfg.logLevel} ${cfg.radioUrl}";
          KillMode = "mixed";
          Restart = "on-failure";
          RestartSec = 5;
          RestartPreventExitStatus = "SIGKILL";
        };
        path = [
          pkgs.ipset
        ];
      };

      # TODO: Build disabled due to npm dependency
      # src/web/otbr-web.service.in
      # otbr-web = {};
    };
  };
}
