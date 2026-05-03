{ config, lib, pkgs, inputs, ... }:
{
    # =========================================================
  # 🖥️ Графика и Wayland
  # =========================================================
  # services.xserver = {
  #   enable = true;

  #   displayManager.startx.enable = true;

  #   desktopManager.lxqt.enable = true;
  # };

  # =========================================================
  # 🧰 Системные пакеты (с комментариями)
  # =========================================================
  environment.systemPackages = with pkgs; [

    # docker
    # docker
    # docker-compose
    # lazydocker
      
    # для bydpi
    

    # для LXQt
    # lxqt.lxqt-session
    # xinit
    # xorgserver
    # openbox

    # # виртуализация с аппартаной поддержкой
    # qemu
    # virt-manager
    # virt-viewer
    # spice
    # spice-gtk
    # cdrkit
    
    

    # privoxy  # перенаправление socks5 в http прокси для игр с поддержкой только http прокси (например, steam)
    
  ];

  # services.privoxy = {
  #   enable = true;

  #   settings = {
  #     listen-address = "0.0.0.0:8118";

  #     forward-socks5 = "/ 127.0.0.1:9050 .";
  #   };
  # };

  # для virtualBox
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;

 

  # docker
  # virtualisation.docker.enable = true;
  # security.polkit.enable = true;
  
}