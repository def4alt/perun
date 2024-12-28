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
  virtualisation.oci-containers.containers."dhcp-helper" = {
    image = "noamokman/dhcp-helper";
    cmd = [ "-s" "172.31.0.100" ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--network=host"
    ];
  };
  systemd.services."docker-dhcp-helper" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-pihole-root.target"
    ];
    wantedBy = [
      "docker-compose-pihole-root.target"
    ];
  };
  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole:latest";
    environment = {
      "DHCP_ACTIVE" = "true";
      "DHCP_END" = "192.168.88.255";
      "DHCP_LEASETIME" = "6";
      "DHCP_ROUTER" = "192.168.88.1";
      "DHCP_START" = "192.168.88.192";
      "DNSMASQ_LISTENING" = "all";
      "DNSSEC" = "true";
      "PIHOLE_DNS_" = "9.9.9.9;149.112.112.112;1.1.1.1";
      "PIHOLE_DOMAIN" = "lan";
      "ServerIP" = "192.168.88.189";
      "TZ" = "Europe/Berlin";
      "VIRTUAL_HOST" = "pihole.local";
      "WEBPASSWORD" = "PASSWORD";
      "WEBTHEME" = "default-dark";
    };
    volumes = [
      "/Users/andrii/homelab/services/pihole/dnsmasq.d:/etc/dnsmasq.d:rw"
      "/Users/andrii/homelab/services/pihole/pihole:/etc/pihole:rw"
    ];
    ports = [
      "53:53/tcp"
      "53:53/udp"
    ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.pihole.entrypoints" = "web";
      "traefik.http.routers.pihole.rule" = "Host(`pihole.local`)";
      "traefik.http.services.pihole.loadbalancer.server.port" = "80";
    };
    dependsOn = [
      "dhcp-helper"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--dns=127.0.0.1"
      "--dns=9.9.9.9"
      "--network-alias=pihole"
      "--network=lan"
      "--network=pihole_backend"
    ];
  };
  systemd.services."docker-pihole" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pihole_backend.service"
    ];
    requires = [
      "docker-network-pihole_backend.service"
    ];
    partOf = [
      "docker-compose-pihole-root.target"
    ];
    wantedBy = [
      "docker-compose-pihole-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-pihole_backend" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f pihole_backend";
    };
    script = ''
      docker network inspect pihole_backend || docker network create pihole_backend --subnet=172.31.0.0/16
    '';
    partOf = [ "docker-compose-pihole-root.target" ];
    wantedBy = [ "docker-compose-pihole-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-pihole-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
