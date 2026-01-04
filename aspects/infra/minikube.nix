_:
{
  flake.aspects.infra-minikube.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        minikube
        conntrack-tools
      ];
    };
}
