{
  config,
  pkgs,
  lib,
  modulesPath,
  specialArgs,
  options
}:
let 
  bootstrapNixosConfig = pkgs.writeScriptBin "bootstrap" ./bootstrap.sh;
in
{
  environment.systemPackages = with pkgs; [
    bootstrapNixosConfig
  ];
}