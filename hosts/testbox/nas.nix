{
  fileSystems."/mnt/nas" = {
    device = "<ip-addrd>:<path>";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=10"
      "nfsvers=4.2"
    ];
  };
}
