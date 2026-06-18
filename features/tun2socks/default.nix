{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sing-box
  ];
}