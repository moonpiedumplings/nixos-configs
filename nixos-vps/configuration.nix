# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix # Include the results of the hardware scan.
      ./containers.nix # OCI containers and networking
    ];

  #virtualisation.useBootLoader = true;
  boot = {
    # we are in a vm so not needed? 
    #loader.grub.enable = true;
    #loader.systemd-boot.enable = true;
    #loader.efi.canTouchEfiVariables = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  nix = {
    autoOptimiseStore = true;
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  networking.hostName = "nixos-vps"; # Define your hostname.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #users.users.root.initialHashedPassword = "$y$j9T$Z8cnbLUJSR3qeWuC2b6YS/$uz1pC.ArrehUtkHQHebbaglWUxAmlPGADZjT0EnXzQ5";
  users.users.moonpie = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     #packages = with pkgs; [];
     initialHashedPassword = "$y$j9T$ZGDLrUl6VP4AiusK96/tx0$1Xb1z61RhXYR8lDlFmJkdS8zyzTnaHL6ArNQBBrEAm0"; # may replace this with a proper secret management scheme later
     openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEQDNqf12xeaYzyBFrOM2R99ciY9i0fPMdb4J64XpU3Tjv7Z5WrYx+LSLCVolzKktTfaSgaIDN8+vswixtjaAXkGW2glvTD0IwaO0N4IQloov3cLZa84I7lkj5jIkZiXJ2zHJZ8bQmayUrSj2yBwYJ61QLs+R0hpEZHfRarBU9vphykACdM6wxSj0YVkFnGlKBxZOZipW6OoKjEkFOHOSH6DYrX3V/TqALYC62iH6jEiLIycxey1vfwkywfsP9V9GlGYHutdwgAgeaN3xUnL8+X6vkQ8cbC2jEuVopodsAAArFYZLVdfAcNc17WYq5y+FX3schGpTo89SZ4Uh9gd4b45h9Hq7h6p7hBF8UCkyqSKnFiPjDJxv5yuY+rYeZ9aJSeCJUYrb1xyOreWnJkhDuYff/1NCewWL8sfuD9IC9BXWBwhxoA/OUfV9KvDBZmYoThlh86ZCQ+uqCR1DIKa1YhPMlT6gzUY01yoMj+B93RpUBUW5LqLDVCL7Qujh/0ns= moonpie@cachyos-x8664" ];
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     micro
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = { 
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      openFirewall = true;
    };
    cockpit = {
      enable = true;
      openFirewall = true;
    };
  };

  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ ... ];
    #allowedUDPPorts = [ ... ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
