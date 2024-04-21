{
  config,
  pkgs,
  lib,
  modulesPath,
  specialArgs,
  options
}:

{
  imports = [
    #./bootstrap.nix
    ./hostkeys.nix
    ./hardware-configuration.nix
  ];

  # show ip on login screen
  environment.etc."issue.d/ip.issue".text = "\\4\n";
  networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";

  networking.hostName = "devops";

  time.timeZone = "Australia/Brisbane";
  services.timesyncd.enable = false; # no ntp from corp
  virtualisation.vmware.guest.enable = true; # timesync on required

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.vm = {
    isNormalUser = true;
  };
  
  # packages for all users
  environment.systemPackages = with pkgs; [
    btop
    git
  ];

  # run unpatched binaries (vscode)
  programs.nix-ld.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
  };

  # Enable podman/docker
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
