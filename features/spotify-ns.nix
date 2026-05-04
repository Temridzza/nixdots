{ config, pkgs, ... }:

let
  nsName = "spotify-ns";
  vethHost = "veth-spotify";
  vethNs = "eth0";
  nsIP = "10.200.1.2";
  hostIP = "10.200.1.1";
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ vethHost ];
  };

  systemd.services.spotify-namespace = {
    description = "Spotify network namespace";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;

    script = ''
      # create namespace
      ip netns add ${nsName} 2>/dev/null || true

      # create veth pair
      ip link add ${vethHost} type veth peer name ${vethNs} netns ${nsName} 2>/dev/null || true

      # host side
      ip addr add ${hostIP}/24 dev ${vethHost} 2>/dev/null || true
      ip link set ${vethHost} up

      # namespace side
      ip netns exec ${nsName} ip addr add ${nsIP}/24 dev ${vethNs} 2>/dev/null || true
      ip netns exec ${nsName} ip link set ${vethNs} up
      ip netns exec ${nsName} ip link set lo up

      # default route
      ip netns exec ${nsName} ip route add default via ${hostIP} 2>/dev/null || true

      # DNS
      mkdir -p /etc/netns/${nsName}
      echo "nameserver 1.1.1.1" > /etc/netns/${nsName}/resolv.conf
    '';
  };
}