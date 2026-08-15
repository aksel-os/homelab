{
  services.prometheus.exporters.node = {
    enable = true;

    extraFlags = [
      "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)"
    ];
  };
}
