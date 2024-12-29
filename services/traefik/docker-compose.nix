# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."traefik" = {
    image = "traefik:v3.2";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    ports = [
      "80:80/tcp"
    ];
    cmd = [ "--api.insecure=true" "--providers.docker=true" "--providers.docker.network=lan" "--entrypoints.web.address=:80" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.api.entrypoints" = "web";
      "traefik.http.routers.api.rule" = "Host(`traefik.local`)";
      "traefik.http.routers.api.service" = "api@internal";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=traefik"
      "--network=lan"
    ];
  };
  systemd.services."docker-traefik" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    partOf = [
      "docker-compose-traefik-root.target"
    ];
    wantedBy = [
      "docker-compose-traefik-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-traefik-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
