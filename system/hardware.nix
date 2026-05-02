# system/hardware.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/80faa9a3-7307-489f-8db6-92e02c719bee";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9CB0-3FDA";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/mnt/steam_games" =
    { device = "/dev/nvme0n1p5";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/92a6118e-898e-48e4-a7a2-665e189467a3"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"
  ];

  hardware.enableRedistributableFirmware = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vulkan-loader
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs; [
      vulkan-loader
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  # звук
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}