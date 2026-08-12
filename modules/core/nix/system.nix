{ self, config, ... }:

{
  system = {
    stateVersion = config.system.nixos.release;
    configurationRevision = self.shortRev or self.dirtyShortRev or "dirty";
  };
}
