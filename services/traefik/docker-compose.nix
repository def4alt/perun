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
      "8080:8080/tcp"
    ];
    cmd = [ "--providers.docker=true" "--providers.docker.network=lan" "--entrypoints.web.address=:80" "--entrypoints.web.http.redirections.entrypoint.to=websecure" "--entrypoints.websecure.address=:443" ];
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
      "docker-compose-whoami-root.target"
    ];
    wantedBy = [
      "docker-compose-whoami-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-whoami-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}