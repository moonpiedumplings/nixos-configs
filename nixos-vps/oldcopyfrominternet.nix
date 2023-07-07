{ config, pkgs, lib, ... }:

{
  imports = [
  ];

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
            HOSTNAME=officemesh.duckdns.org     #your hostname
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

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      #51820 # Wireguard
    ];
  };

  /*networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.3/24" ];
      privateKeyFile = "/root/wireguard-keys/private";
      peers = [
        {
          publicKey = "UDyx2aHj21Qn7YmxzhVZq8k82Ke+1f5FaK8N1r34EXY=";
          allowedIPs = [ "10.100.0.1" ];
          endpoint = "158.69.224.168:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
  */

  /*boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
  };*/

  #boot.loader.raspberryPi = {
  #  enable = true;
  #  version = 4;
  #};
  #boot.loader.grub.enable = false;
  #boot.loader.generic-extlinux-compatible.enable = true;

  #hardware.cpu.intel.updateMicrocode = lib.mkForce false;

  environment.systemPackages = with pkgs; [
  ];

  nix = {
    autoOptimiseStore = true;
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };


  nixpkgs.config = {
    allowUnfree = true;
  };
  #powerManagement.cpuFreqGovernor = "ondemand";
  #system.stateVersion = "21.03";
  #swapDevices = [ { device = "/swapfile"; size = 3072; } ];
}