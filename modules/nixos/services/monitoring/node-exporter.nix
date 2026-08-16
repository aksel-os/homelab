{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";

    extraFlags = [
      "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    ];
  };
}
