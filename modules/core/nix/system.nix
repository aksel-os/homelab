{ self, ... }:

{
  system = {
    stateVersion = "26.05";
    configurationRevision = self.shortRev or self.dirtyShortRev or "dirty";
  };
}
