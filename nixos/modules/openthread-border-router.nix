
{ lib, config, pkgs, inputs,  ... }: 


let
  cfg = config.services.openthread-border-router;
in 
{
  options.services.openthread-border-router = {
    enable = lib.mkEnableOption "Enable the OpenThread Border Router";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.mrene-nur.packages.${pkgs.system}.openthread-border-router;
      description = "The openthread-border-router package";
    };

    radioDevice = lib.mkOption {
      type = lib.types.str;
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

    rest = {
      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 8081;
      };
    };

    web = {
      enable = lib.mkEnableOption "Enable the web interface";
      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 8082;
      };
    };

    radio = {
      device = lib.mkOption {
        type = lib.types.str;
        default = "/dev/ttyUSB0";
        description = "The device name of the serial port of the radio device. Ignored if url is manually set.";
      };

      baudRate = lib.mkOption {
        type = lib.types.int;
        default = 115200;
        description = "The baud rate of the radio device. Ignored if url is manually set.";
      };

      flowControl = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable hardware flow control. Ignored if url is manually set.";
      };

      extraUrlParams = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Extra URL query string parameters";
        example = "bus-latency=100&region=ca";
      };

      url = lib.mkOption {
        #TODO: There can technically be multiple URL if a device has more than one radio
        type = lib.types.str;
        description = "The URL of the radio device to use";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.openthread-border-router.radio.url = "spinel+hdlc+uart://${cfg.radio.device}?" +
      lib.concatStringsSep "&" (
             (lib.optional (cfg.radio.baudRate != 115200) "uart-baudrate=${toString cfg.radio.baudRate}")
          ++ (lib.optional cfg.radio.flowControl "uart-flow-control")
          ++ (lib.optional (cfg.radio.extraUrlParams != "") cfg.radio.extraUrlParams)
      );

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
      # src/agent/otbr-agent.service.in
      # The agent keeps its local state in /var/lib/thread
      otbr-agent = {
        description = "OpenThread Border Router Agent";
        wantedBy = [ "multi-user.target" ];
        requires =  [ "dbus.socket" ];
        after = [ "dbus.socket" ];
        serviceConfig = {
          ExecStart = (lib.concatStringsSep " " (
               [(lib.getExe' cfg.package "otbr-agent")]
            ++ ["--verbose" "--syslog-disable"]
            ++ ["--backbone-ifname ${cfg.backboneInterface}"]
            ++ ["--thread-ifname ${cfg.interfaceName}"]
            ++ ["--debug-level ${toString cfg.logLevel}"]
            ++ (lib.optional (cfg.rest.listenPort != 0) "--rest-listen-port ${toString cfg.rest.listenPort}")
            ++ (lib.optional (cfg.rest.listenAddress != "") "--rest-listen-address ${cfg.rest.listenAddress}")
            ++ [cfg.radio.url]
          ));
          KillMode = "mixed";
          Restart = "on-failure";
          RestartSec = 5;
          RestartPreventExitStatus = "SIGKILL";
        };
        path = [ pkgs.ipset ];
      };

      # src/web/otbr-web.service.in
      otbr-web = {
        description = "OpenThread Border Router Web";
        after = [ "otbr-agent.service"];
        serviceConfig = {
          ExecStart = (lib.concatStringsSep " " (
               [
                (lib.getExe' cfg.package "otbr-web")
                "-I" "${cfg.interfaceName}"
                "-d" "${toString cfg.logLevel}"
               ] 
               ++ (lib.optional (cfg.web.listenAddress != "") "-a ${cfg.web.listenAddress}")
               ++ (lib.optional (cfg.web.listenPort != 0) "-p ${toString cfg.web.listenPort}")
          ));
        };
      };
    };
  };
}
