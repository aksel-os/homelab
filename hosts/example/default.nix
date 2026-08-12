{ inputs, ... }:

{
  imports = [ ./disko.nix ];

  modules = [ inputs.disko.nixosModules.disko ];
}
