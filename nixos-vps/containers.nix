{ config, lib, pkgs, ... }:


{
    virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        "npm" = {
          image = "docker.io/jc21/nginx-proxy-manager:latest";
          dependsOn = [ ];
          volumes = [
            "/srv/container/home-assistant:/config"
            "/etc/localtime:/etc/localtime:ro"
            "/home/moonpie/"

          ];
          autoStart = true;
          extraOptions = [ "--pod=main" "--pull=newer" ];
        };
        "meshcentral" = {
          image = "docker.io/typhonragewind/meshcentral:latest";
          volumes = [
            "/home/moonpie/meshcentral/meshcentral/data:/opt/meshcentral/meshcentral-data"
            "/home/moonpie/meshcentral/user_files:/opt/meshcentral/meshcentral-files"
          ];
          autoStart = true;
          environment = let secrets = import ../../secrets/postgres.nix; in {
            HOSTNAME="officemesh.duckdns.org";     #your hostname
            REVERSE_PROXY="172.18.0.3";     #set to your reverse proxy IP if you want to put meshcentral behind a reverse proxy
            REVERSE_PROXY_TLS_PORT="443";
            IFRAME="false";    #set to true if you wish to enable iframe support
            ALLOW_NEW_ACCOUNTS="true";    #set to false if you want disable self-service creation of new accounts besides the first (admin)
            WEBRTC="false";  #set to true to enable WebRTC - per documentation it is not officially released with meshcentral, but is solid enough to work with. Use with caution
          };
          extraOptions = [ "--pod=main" "--pull=newer" ]; 
        };
      };
    };
  };

  systemd.services.create-hass-pod = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      #"podman-postgres-hass.service"
      #"podman-home-assistant.service"
    ];
    script = with pkgs; ''
      ${podman}/bin/podman pod exists main-pod|| \
        ${podman}/bin/podman pod create --name home-assistant-pod -p '0.0.0.0:8123:8123 --network bridge'
    '';
  };

}