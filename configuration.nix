{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "23.11";

  imports = [
    ./boot.nix
    #./bootstrap.nix
    ./hardware-configuration.nix
    ./cacert.nix # ca cert
    ./hostkeys.nix # ssh host keys
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
    extraGroups = [];
    # per user packages, these should go in per dev repo when vscode can set env from repo 
    # packages = with pkgs; [
    #   nodejs-18_x
    #   azure-cli
    #   (python311.withPackages(ps: with ps; [ mkdocs ]))
    # ];
  };
  
  # packages for all users
  environment.systemPackages = with pkgs; [
    btop
    git
    nixd
  ];

  # run unpatched binaries (vscode)
  programs.nix-ld.enable = true;

  # direnv for vscode
  programs.direnv.enable = true;

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
}
